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

require 'ronin/recon/message/value'
require 'ronin/recon/message/worker_started'
require 'ronin/recon/message/worker_stopped'
require 'ronin/recon/message/job_started'
require 'ronin/recon/message/job_completed'
require 'ronin/recon/message/job_failed'
require 'ronin/recon/message/shutdown'
require 'ronin/core/params/mixin'

require 'async/queue'

module Ronin
  module Recon
    #
    # Contains the `Async::Task` objects for a worker, that process messages
    # from the input queue and sends messages to the output queue.
    #
    # @api private
    #
    class WorkerPool

      # The recon worker's ID.
      #
      # @return [String]
      attr_reader :id

      # The number of async worker tasks to spawn.
      #
      # @return [Integer]
      attr_reader :concurrency

      # The worker object.
      #
      # @return [Worker]
      attr_reader :worker

      # The input queue for the worker(s).
      #
      # @return [Async::Queue]
      attr_reader :input_queue

      # The output queue for the worker(s).
      #
      # @return [Async::Queue]
      attr_reader :output_queue

      # The logger for debug messages.
      #
      # @return [Console::Logger]
      attr_reader :logger

      #
      # Initializes the worker pool.
      #
      # @param [Worker] worker
      #   The initialized worker object.
      #
      # @param [Integer] concurrency
      #   The number of async tasks to spawn.
      #
      # @param [Async::Queue] output_queue
      #   The output queue to send discovered values to.
      #
      # @param [Console::Logger] logger
      #   The console logger object.
      #
      def initialize(worker, concurrency:  worker.class.concurrency,
                             output_queue: ,
                             params: nil,
                             logger: Console.logger)
        @worker      = worker
        @concurrency = concurrency

        @input_queue  = Async::Queue.new
        @output_queue = output_queue

        @logger = logger

        @tasks  = nil
      end

      #
      # Routes a message to the worker.
      #
      # @param [Message::Value, Message::STOP] mesg
      #   The message to route.
      #
      def enqueue_mesg(mesg)
        case mesg
        when Message::SHUTDOWN
          # push the Stop message for each worker task
          @concurrency.times do
            @input_queue.enqueue(mesg)
          end
        else
          @input_queue.enqueue(mesg)
        end
      end

      #
      # Runs the worker.
      #
      def run
        # HACK: for some reason `until (mesg = ...) == Message::SHUTDOWn)`
        # causes `Message::SHUTDOWN` objects to slip by. Changing it to a
        # `loop do` fixes this for some reason.
        loop do
          if (mesg = @input_queue.dequeue) == Message::SHUTDOWN
            break
          end

          value = mesg.value

          enqueue(Message::JobStarted.new(@worker,value))

          begin
            @worker.process(value) do |result|
              @logger.debug("Output value yielded: #{@worker} #{value.inspect} -> #{result.inspect}")

              new_value = Message::Value.new(result, worker: @worker,
                                                     parent: value,
                                                     depth:  mesg.depth + 1)

              enqueue(new_value)
            end

            enqueue(Message::JobCompleted.new(@worker,value))
          rescue StandardError => error
            enqueue(Message::JobFailed.new(@worker,value,error))
          end
        end

        stopped!
      end

      #
      # Starts the worker pool.
      #
      # @param [Async::Task] task
      #   The optional async task to register the worker under.
      #
      def start(task=Async::Task.current)
        # mark the worker as running
        started!

        @tasks = []

        @concurrency.times do
          @tasks << task.async { run }
        end
      end

      #
      # Marks the worker pool as running.
      #
      def started!
        # send a message to the engine that the worker pool has started
        enqueue(Message::WorkerStarted.new(@worker))
      end

      #
      # Marks the worker pool as stopped.
      #
      def stopped!
        # send a message to the engine that the worker pool has stopped
        enqueue(Message::WorkerStopped.new(@worker))
      end

      private

      #
      # Sends a message to the output queue.
      #
      # @param [Message::JobStarted, Message::JobCompleted, Message::JobFailed, Message::Value] mesg
      #   The message object to enqueue.
      #
      def enqueue(mesg)
        @output_queue.enqueue(mesg)
      end

    end
  end
end
