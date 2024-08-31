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

require_relative 'config'
require_relative 'workers'
require_relative 'worker_pool'
require_relative 'value_status'
require_relative 'graph'
require_relative 'scope'
require_relative 'message/worker_started'
require_relative 'message/worker_stopped'
require_relative 'message/job_started'
require_relative 'message/job_completed'
require_relative 'message/job_failed'
require_relative 'message/value'
require_relative 'message/shutdown'

require 'set'
require 'console/logger'
require 'async'
require 'async/queue'

module Ronin
  module Recon
    #
    # The recon engine which enqueues and dequeues values from workers.
    #
    class Engine

      # The configuration for the engine.
      #
      # @return [Config]
      attr_reader :config

      # The workers to use.
      #
      # @return [Workers]
      attr_reader :workers

      # The scope to constrain recon to.
      #
      # @return [Scope]
      attr_reader :scope

      # The maximum depth to recon.
      #
      # @return [Integer, nil]
      #
      # @api public
      attr_reader :max_depth

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

      # The common logger for the engine.
      #
      # @return [Console::Logger]
      #
      # @api private
      attr_reader :logger

      #
      # Initializes the recon engine.
      #
      # @param [Array<Value>] values
      #   The values to start performing recon on.
      #
      # @param [Array<Value>] ignore
      #   The values to ignore while performing recon.
      #
      # @param [Integer, nil] max_depth
      #   The maximum depth to limit recon to. If not specified recon will
      #   continue until there are no more new values discovered.
      #
      # @param [String, nil] config_file
      #   The path to the configuration file.
      #
      # @param [Config, nil] config
      #   The configuration for the engine. If specified, it will override
      #   `config_file:`.
      #
      # @param [Workers, Array<Class<Worker>>, nil] workers
      #   The worker classes to use. If specified, it will override the workers
      #   specified in `config.workers`.
      #
      # @param [Console::Logger] logger
      #   The common logger for the recon engine.
      #
      # @yield [self]
      #   If a block is given it will be passed the newly created engine.
      #
      # @yieldparam [Engine] self
      #   The newly initialized engine.
      #
      # @api public
      #
      def initialize(values, ignore:      [],
                             max_depth:   nil,
                             config:      nil,
                             config_file: nil,
                             workers:     nil,
                             logger:      Console.logger)
        @config  = if    config      then config
                   elsif config_file then Config.load(config_file)
                   else                   Config.default
                   end
        @workers = workers || Workers.load(@config.workers)
        @logger  = logger

        @scope     = Scope.new(values, ignore: ignore)
        @max_depth = max_depth

        @on_value_callbacks         = []
        @on_connection_callbacks    = []
        @on_job_started_callbacks   = []
        @on_job_completed_callbacks = []
        @on_job_failed_callbacks    = []

        @value_status = ValueStatus.new
        @graph        = Graph.new

        yield self if block_given?

        @worker_classes    = {}
        @worker_pools      = {}
        @worker_pool_count = 0
        @output_queue      = Async::Queue.new

        @workers.each do |worker_class|
          add_worker(worker_class)
        end
      end

      #
      # The discovered recon values.
      #
      # @return [Set<Value>]
      #   The set of discovered recon values.
      #
      # @api public
      #
      def values
        @graph.nodes
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
      # @yieldparam [Value] value
      #   A value discovered by one of the recon workers.
      #
      # @yieldparam [Value] parent
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
          engine.run(task)
        end

        return engine
      end

      #
      # The main recon engine event loop.
      #
      # @param [Async::Task] task
      #   The parent async task.
      #
      # @api private
      #
      def run(task=Async::Task.current)
        # enqueue the scope values for processing
        # rubocop:disable Style/HashEachMethods
        @scope.values.each do |value|
          enqueue_value(value)
        end
        # rubocop:enable Style/HashEachMethods

        # output consumer task
        task.async do
          until (@value_status.empty? && @output_queue.empty?)
            process(@output_queue.dequeue)
          end

          shutdown!
        end

        # start all work groups
        @worker_pools.each_value do |worker_pools|
          worker_pools.each do |worker_pool|
            worker_pool.start(task)
          end
        end
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
      def add_worker(worker_class, params: nil, concurrency: nil)
        params      ||= @config.params[worker_class.id]
        concurrency ||= @config.concurrency[worker_class.id]

        worker      = worker_class.new(params: params)
        worker_pool = WorkerPool.new(worker, concurrency:  concurrency,
                                             output_queue: @output_queue,
                                             logger:       @logger)

        worker_class.accepts.each do |value_class|
          (@worker_classes[value_class] ||= []) << worker_class
          (@worker_pools[value_class]   ||= []) << worker_pool
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
      # @yieldparam [Value] value
      #   A discovered value value.
      #
      # @yieldparam [Value] parent
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
        when :value         then @on_value_callbacks         << block
        when :connection    then @on_connection_callbacks    << block
        when :job_started   then @on_job_started_callbacks   << block
        when :job_completed then @on_job_completed_callbacks << block
        when :job_failed    then @on_job_failed_callbacks    << block
        else
          raise(ArgumentError,"unsupported event type: #{event.inspect}")
        end
      end

      private

      #
      # Calls the `on(:job_started) { ... }` callbacks.
      #
      # @param [Worker] worker
      #   The worker that is processing the value.
      #
      # @param [Value] value
      #   The value that is being processed.
      #
      # @api private
      #
      def on_job_started(worker,value)
        @on_job_started_callbacks.each do |callback|
          callback.call(worker.class,value)
        end
      end

      #
      # Calls the `on(:job_completed) { ... }` callbacks.
      #
      # @param [Worker] worker
      #   The worker that processed the value.
      #
      # @param [Value] value
      #   The value that was processed.
      #
      # @api private
      #
      def on_job_completed(worker,value)
        @on_job_completed_callbacks.each do |callback|
          callback.call(worker.class,value)
        end
      end

      #
      # Calls the `on(:job_failed) { ... }` callbacks.
      #
      # @param [Worker] worker
      #   The worker that raised the exception.
      #
      # @param [Value] value
      #   The value that was being processed.
      #
      # @param [RuntimeError] exception
      #   The exception raised by the worker.
      #
      # @api private
      #
      def on_job_failed(worker,value,exception)
        @on_job_failed_callbacks.each do |callback|
          callback.call(worker.class,value,exception)
        end
      end

      #
      # Calls the `on(:value) { ... }` callbacks.
      #
      # @param [Worker] worker
      #   The worker that discovered the value.
      #
      # @param [Value] value
      #   The newly discovered value.
      #
      # @param [Value] parent
      #   The parent value associated with the new value.
      #
      # @api private
      #
      def on_value(worker,value,parent)
        @on_value_callbacks.each do |callback|
          case callback.arity
          when 1 then callback.call(value)
          when 2 then callback.call(value,parent)
          else        callback.call(worker.class,value,parent)
          end
        end
      end

      #
      # Calls the `on(:connection) { ... }` callbacks.
      #
      # @param [Worker] worker
      #   The worker that discovered the value.
      #
      # @param [Value] value
      #   The discovered value.
      #
      # @param [Value] parent
      #   The parent value associated with the value.
      #
      # @api private
      #
      def on_connection(worker,value,parent)
        @on_connection_callbacks.each do |callback|
          case callback.arity
          when 2 then callback.call(value,parent)
          else        callback.call(worker.class,value,parent)
          end
        end
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
        when Message::WorkerStarted then process_worker_started(mesg)
        when Message::WorkerStopped then process_worker_stopped(mesg)
        when Message::JobStarted    then process_job_started(mesg)
        when Message::JobCompleted  then process_job_completed(mesg)
        when Message::JobFailed     then process_job_failed(mesg)
        when Message::Value         then process_value(mesg)
        else
          raise(NotImplementedError,"unable to process message: #{mesg.inspect}")
        end
      end

      #
      # Handles when a worker has started.
      #
      # @param [Message::WorkerStarted] mesg
      #   The worker started message.
      #
      # @api private
      #
      def process_worker_started(mesg)
        @logger.debug("Worker started: #{mesg.worker}")
        @worker_pool_count += 1
      end

      #
      # Handles when a worker has stopped.
      #
      # @param [Message::WorkerStopped] mesg
      #   The worker stopped message.
      #
      # @api private
      #
      def process_worker_stopped(mesg)
        @logger.debug("Worker shutdown: #{mesg.worker}")
        @worker_pool_count -= 1
      end

      #
      # Handles when a worker job is started.
      #
      # @param [Message::JobStarted] mesg
      #   The job started message.
      #
      # @api private
      #
      def process_job_started(mesg)
        worker = mesg.worker
        value  = mesg.value

        @logger.debug("Job started: #{worker.class} #{value.inspect}")
        on_job_started(worker,value)

        @value_status.job_started(worker.class,value)
      end

      #
      # Handles when a worker job is completed.
      #
      # @param [Message::JobStarted] mesg
      #   The job completed message.
      #
      # @api private
      #
      def process_job_completed(mesg)
        worker = mesg.worker
        value  = mesg.value

        @logger.debug("Job completed: #{worker.class} #{value.inspect}")
        on_job_completed(worker,value)

        @value_status.job_completed(worker.class,value)
      end

      #
      # Handles when a worker job fails.
      #
      # @param [Message::JobFailed] mesg
      #   The job failed message.
      #
      # @api private
      #
      def process_job_failed(mesg)
        worker    = mesg.worker
        value     = mesg.value
        exception = mesg.exception

        @logger.debug("Job failed: #{worker.class} #{value.inspect} #{exception.inspect}")
        on_job_failed(worker,value,exception)

        @value_status.job_failed(worker.class,value)
      end

      #
      # Handles when a value is received.
      #
      # @param [Message::Value] mesg
      #   The value message.
      #
      # @api private
      #
      def process_value(mesg)
        worker = mesg.worker
        value  = mesg.value
        parent = mesg.parent

        @logger.debug("Output value dequeued: #{worker.class} #{value.inspect}")

        # check if the new value is "in scope"
        if @scope.include?(value)
          # check if the value hasn't been seen yet?
          if @graph.add_node(value)
            @logger.debug("Added value #{value.inspect} to graph")
            on_value(worker,value,parent)

            # check if the message has exceeded the max depth
            if @max_depth.nil? || mesg.depth < @max_depth
              @logger.debug("Re-enqueueing value: #{value.inspect} ...")

              # feed the message back into the engine
              enqueue_mesg(mesg)
            end
          end

          if @graph.add_edge(value,parent)
            @logger.debug("Added a new connection between #{value.inspect} and #{parent.inspect} to the graph")
            on_connection(worker,value,parent)
          end
        end
      end

      #
      # Enqueues a message for processing.
      #
      # @param [Message::Value, Message::SHUTDOWN] mesg
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

            @worker_pools[value.class].each do |worker_pool|
              worker_pool.enqueue_mesg(mesg)
            end
          end
        when Message::SHUTDOWN
          @logger.debug("Shutting down ...")

          @worker_pools.each_value do |worker_pools|
            worker_pools.each do |worker_pool|
              @logger.debug("Shutting down worker: #{worker_pool.worker} ...")

              worker_pool.enqueue_mesg(mesg)
            end
          end
        else
          raise(NotImplementedError,"unable to handle message: #{mesg.inspect}")
        end
      end

      #
      # Sends a new value into the recon engine for processing.
      #
      # @param [Value] value
      #   The value object to enqueue.
      #
      # @api private
      #
      def enqueue_value(value)
        @graph.add_node(value)
        enqueue_mesg(Message::Value.new(value))
      end

      #
      # Sends the shutdown message and waits for all worker pools to shutdown.
      #
      # @api private
      #
      def shutdown!
        enqueue_mesg(Message::SHUTDOWN)

        # wait until all workers report that they have exited
        until @worker_pool_count == 0
          process(@output_queue.dequeue)
        end
      end

    end
  end
end
