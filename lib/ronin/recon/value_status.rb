# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2026 Hal Brodigan (postmodern.mod3@gmail.com)
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

module Ronin
  module Recon
    #
    # Represents the status of every value across all queues and workers.
    #
    class ValueStatus

      attr_reader :values

      def initialize
        @values = {}
      end

      #
      # Records that a value was enqueued for the given worker class.
      #
      # @param [Value] value
      #
      # @param [Class<Worker>] worker_class
      #
      def value_enqueued(worker_class,value)
        (@values[value] ||= {})[worker_class] = :enqueued
      end

      #
      # Records that a worker has dequeued the value and started processing it.
      #
      # @param [Value] value
      #
      # @param [Class<Worker>] worker_class
      #
      def job_started(worker_class,value)
        (@values[value] ||= {})[worker_class] = :working
      end

      #
      # Records that a worker has completed processing the value.
      #
      # @param [Value] value
      #
      # @param [Class<Worker>] worker_class
      #
      def job_completed(worker_class,value)
        if (worker_statuses = @values[value])
          worker_statuses.delete(worker_class)

          if worker_statuses.empty?
            @values.delete(value)
          end
        end
      end

      alias job_failed job_completed

      #
      # Determines if there are no more values within the queue or being
      # processed by any of the workers.
      #
      # @return [Boolean]
      #
      def empty?
        @values.empty?
      end

    end
  end
end
