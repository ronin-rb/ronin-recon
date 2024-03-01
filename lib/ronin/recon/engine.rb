# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)
#
# ronin-recon is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-recon is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-recon.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/recon/worker_tasks'
require 'ronin/recon/value_status'
require 'ronin/recon/graph'
require 'ronin/recon/scope'
require 'ronin/recon/message/worker_started'
require 'ronin/recon/message/worker_stopped'
require 'ronin/recon/message/job_started'
require 'ronin/recon/message/job_completed'
require 'ronin/recon/message/job_failed'
require 'ronin/recon/message/value'
require 'ronin/recon/message/shutdown'
require 'ronin/recon/worker_set'

require 'set'
require 'console/logger'
require 'async/queue'

module Ronin
  module Recon
    #
    # The recon engine which enqueues and dequeues values from workers.
    #
    class Engine

      # The scope to constrain recon to.
      #
      # @return [Scope]
      attr_reader :scope

      # The status of all values in the queue.
      #
      # @return [ValueStatus]
      attr_reader :value_status

      # The recon engine graph of discovered values.
      #
      # @return [Graph]
      #
      # @api public
      attr_reader :graph

      # The maximum depth to recon.
      #
      # @return [Integer, nil]
      #
      # @api public
      attr_reader :max_depth

      #
      # Initializes the recon engine.
      #
      # @yield [self]
      #   If a block is given it will be passed the newly created engine.
      #
      # @yieldparam [Engine] self
      #   The newly initialized engine.
      #
      # @yieldparam [Values::Value] parent
      #   The parent value which is associated to the discovered value.
      #
      # @api public
      #
      def initialize(values, workers:   WorkerSet.default,
                             max_depth: nil,
                             logger:    Console.logger,
                             ignore:    [])
        @scope = Scope.new(values, ignore: ignore)

        @worker_classes    = {}
        @worker_tasks      = {}
        @worker_task_count = 0

        @value_status = ValueStatus.new
        @graph        = Graph.new
        @max_depth    = max_depth
        @output_queue = Async::Queue.new

        @value_callbacks         = []
        @connection_callbacks    = []
        @job_started_callbacks   = []
        @job_completed_callbacks = []
        @job_failed_callbacks    = []

        @logger = logger

        workers.each do |worker_class|
          add_worker(worker_class)
        end

        yield self if block_given?
      end

      #
      # Runs the recon engine with the given initial values.
      #
      # @param [Array<Value>] values
      #   The initial values to start the recon engine with.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#initialize}.
      #
      # @yield [value, (value, parent)]
      #   The given block will be passed each discovered value during recon.
      #   If the block accepts two arguments the value and it's parent value
      #   will be passed to the block.
      #
      # @yieldparam [Values::Value] value
      #   A value discovered by one of the recon workers.
      #
      # @yieldparam [Values::Value] parent
      #   The parent value which is associated to the discovered value.
      #
      # @return [Engine]
      #   The engine instance.
      #
      # @api public
      #
      def self.run(values,**kwargs,&block)
        engine = new(values,**kwargs,&block)

        # start the engine in it's own Async task
        Async do |task|
          # start the engine
          engine.start(task)
        end

        return engine
      end

      #
      # Adds a worker class to the engine.
      #
      # @param [Class<Worker>] worker_class
      #   The worker class.
      #
      # @param [Hash{Symbol => Object}, nil] params
      #   Additional params for {Worker#initialize}.
      #
      # @api private
      #
      def add_worker(worker_class, concurrency: worker_class.concurrency,
                                   params: nil)
        worker       = worker_class.new(params: params)
        worker_tasks = WorkerTasks.new(worker, concurrency:  concurrency,
                                               output_queue: @output_queue,
                                               logger:       @logger)

        worker_class.accepts.each do |value_class|
          (@worker_classes[value_class] ||= []) << worker_class
          (@worker_tasks[value_class]   ||= []) << worker_tasks
        end
      end

      #
      # Registers a callback for the given event.
      #
      # @param [:value, :connection, :job_started, :job_completed, :job_failed] event
      #   The event type to register the callback for.
      #
      # @yield [value, (value, parent), (worker_class, value, parent)]
      #   If `:value` is given, then the given block will be passed each new value.
      #
      # @yield [(value, parent), (worker_class, value, parent)]
      #   If `:connection` is given, then the given block will be passed the
      #   discovered value and it's parent value.
      #
      # @yield [worker_class, value]
      #   If `:job_started` is given, then the given block will be passed the
      #   worker class and the input value.
      #
      # @yield [worker_class, value]
      #   If `:job_completed` is given, then the given block will be passed the
      #   worker class and the input value.
      #
      # @yield [worker_class, value, exception]
      #   If `:job_failed` is given, then any exception raised by a worker will
      #   be passed to the given block.
      #
      # @yieldparam [Values::Value] value
      #   A discovered value value.
      #
      # @yieldparam [Values::Value] parent
      #   The parent value of the value.
      #
      # @yieldparam [Class<Worker>] worker_class
      #   The worker class.
      #
      # @yieldparam [RuntimeError] exception
      #   An exception that was raised by a worker.
      #
      # @api public
      #
      def on(event,&block)
        case event
        when :value         then @value_callbacks         << block
        when :connection    then @connection_callbacks    << block
        when :job_started   then @job_started_callbacks   << block
        when :job_completed then @job_completed_callbacks << block
        when :job_failed    then @job_failed_callbacks    << block
        else
          raise(ArgumentError,"unsupported event type: #{event.inspect}")
        end
      end

      #
      # Enqueues a message for processing.
      #
      # @param [Message::Value, Message::STOP] mesg
      #   The message object.
      #
      # @raise [NotImplementedError]
      #   An unsupported message type was given.
      #
      # @api private
      #
      def enqueue_mesg(mesg)
        case mesg
        when Message::Value
          value = mesg.value

          if (worker_classes = @worker_classes[value.class])
            worker_classes.each do |worker_class|
              @logger.debug("Value enqueued: #{worker_class} #{value.inspect}")

              @value_status.value_enqueued(worker_class,value)
            end

            @worker_tasks[value.class].each do |worker_task|
              worker_task.enqueue_mesg(mesg)
            end
          end
        when Message::SHUTDOWN
          @logger.debug("Shutting down ...")

          @worker_tasks.each_value do |worker_tasks|
            worker_tasks.each do |worker_task|
              @logger.debug("Shutting down worker: #{worker_task.worker} ...")

              worker_task.enqueue_mesg(mesg)
            end
          end
        else
          raise(NotImplementedError,"unable to handle message: #{mesg.inspect}")
        end
      end

      #
      # Sends a new value into the recon engine for processing.
      #
      # @param [Values::Value] value
      #   The value object to enqueue.
      #
      # @api public
      #
      def enqueue_value(value)
        @graph.add_node(value)
        enqueue_mesg(Message::Value.new(value))
      end

      #
      # The main recon engine event loop.
      #
      # @api private
      #
      def run
        until (@value_status.empty? && @output_queue.empty?)
          process(@output_queue.dequeue)
        end

        shutdown!
      end

      #
      # Processes a message.
      #
      # @param [Message::WorkerStarted, Message::WorkerStopped, Message::JobStarted, Message::JobCompleted, Message::JobFailed, Message::Value] mesg
      #   A queue message to process.
      #
      # @raise [NotImplementedError]
      #   An unknown message type was given.
      #
      # @api private
      #
      def process(mesg)
        case mesg
        when Message::WorkerStarted
          @logger.debug("Worker started: #{mesg.worker}")
          @worker_task_count += 1
        when Message::WorkerStopped
          @logger.debug("Worker shutdown: #{mesg.worker}")
          @worker_task_count -= 1
        when Message::JobStarted
          @logger.debug("Job started: #{mesg.worker.class} #{mesg.value.inspect}")
          @job_started_callbacks.each do |callback|
            callback.call(mesg.worker.class,mesg.value)
          end

          @value_status.job_started(mesg.worker.class,mesg.value)
        when Message::JobCompleted
          @logger.debug("Job completed: #{mesg.worker.class} #{mesg.value.inspect}")

          @job_completed_callbacks.each do |callback|
            callback.call(mesg.worker.class,mesg.value)
          end

          @value_status.job_completed(mesg.worker.class,mesg.value)
        when Message::JobFailed
          @logger.debug("Job failed: #{mesg.worker.class} #{mesg.value.inspect} #{mesg.exception.inspect}")

          @job_failed_callbacks.each do |callback|
            callback.call(mesg.worker.class,mesg.value,mesg.exception)
          end

          @value_status.job_failed(mesg.worker.class,mesg.value)
        when Message::Value
          value  = mesg.value
          parent = mesg.parent

          @logger.debug("Output value dequeued: #{mesg.worker.class} #{mesg.value.inspect}")

          # check if the new value is "in scope"
          if @scope.include?(value)
            # check if the value hasn't been seen yet?
            if @graph.add_node(value)
              @logger.debug("Added value #{value.inspect} to graph")

              @value_callbacks.each do |callback|
                case callback.arity
                when 1 then callback.call(value)
                when 2 then callback.call(value,parent)
                else        callback.call(mesg.worker.class,value,parent)
                end
              end

              # check if the message has exceeded the max depth
              if @max_depth.nil? || mesg.depth < @max_depth
                @logger.debug("Re-enqueueing value: #{value.inspect} ...")

                # feed the message back into the engine
                enqueue_mesg(mesg)
              end
            end

            if @graph.add_edge(value,parent)
              @logger.debug("Added a new connection between #{value.inspect} and #{parent.inspect} to the graph")

              @connection_callbacks.each do |callback|
                case callback.arity
                when 2 then callback.call(value,parent)
                else        callback.call(mesg.worker.class,value,parent)
                end
              end
            end
          end
        else
          raise(NotImplementedError,"unable to process message: #{mesg.inspect}")
        end
      end

      #
      # Starts the recon engine.
      #
      # @param [Async::Task] task
      #   The async task to run the recon engine under.
      #
      # @api private
      #
      def start(task=Async::Task.current)
        # enqueue the scope values for processing
        # rubocop:disable Style/HashEachMethods
        @scope.values.each do |value|
          enqueue_value(value)
        end
        # rubocop:enable Style/HashEachMethods

        # output consumer task
        task.async { run }

        # start all work groups
        @worker_tasks.each_value do |worker_tasks|
          worker_tasks.each do |worker_task|
            worker_task.start(task)
          end
        end
      end

      #
      # Sends the shutdown message and waits for all worker tasks to shutdown.
      #
      # @api private
      #
      def shutdown!
        enqueue_mesg(Message::SHUTDOWN)

        # wait until all workers report that they have exited
        until @worker_task_count == 0
          process(@output_queue.dequeue)
        end
      end

      #
      # The discovered recon values.
      #
      # @return [Set<Value>]
      #   The set of discovered recon values.
      #
      def values
        @graph.nodes
      end

    end
  end
end
