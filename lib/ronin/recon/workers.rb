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

require_relative 'registry'

module Ronin
  module Recon
    #
    # Represents a set of recon worker classes.
    #
    # @api private
    #
    class Workers

      include Enumerable

      # The worker classes in the set.
      #
      # @return [Set<Class<Worker>>]
      attr_reader :classes

      #
      # Initializes the workers.
      #
      # @param [Array<Class<Worker>>, Set<Class<Worker>>] workers
      #   The set of worker classes.
      #
      def initialize(workers=Set.new)
        @classes = workers.to_set
      end

      #
      # Loads the worker classes.
      #
      # @param [Enumerable<String>] worker_ids
      #   The list of worker IDs to load.
      #
      # @return [Workers]
      #
      def self.load(worker_ids)
        workers = new

        worker_ids.each do |worker_id|
          workers.load(worker_id)
        end

        return workers
      end

      #
      # Alias for {load}.
      #
      # @param [Array<String>] worker_ids
      #   The array of worker IDs to load.
      #
      # @return [Workers]
      #
      def self.[](*worker_ids)
        load(worker_ids)
      end

      #
      # Loads all workers.
      #
      # @return [Workers]
      #
      def self.all
        load(Recon.list_files)
      end

      #
      # Loads all workers under a specific category.
      #
      # @param [String] name
      #   The category name.
      #
      # @return [Workers]
      #
      def self.category(name)
        load(
          Recon.list_files.select { |worker_id|
            worker_id.start_with?("#{name}/")
          }
        )
      end

      #
      # Enumerates over the worker classes within the set.
      #
      # @yield [worker]
      #   If a block is given, it will be passed every worker class within the
      #   set.
      #
      # @yieldparam [Class<Worker>] worker
      #   A worker class within the set.
      #
      # @return [Enumerator]
      #   If no block is given, an Enumerator object will be returned.
      #
      def each(&block)
        @classes.each(&block)
      end

      #
      # Adds another set of workers to the workers.
      #
      # @param [Workers, Array<Class<Worker>>] other
      #
      # @return [Workers]
      #
      def +(other)
        other_workers = other.to_set

        self.class.new((@classes + other_workers).uniq)
      end

      #
      # Adds the worker class to the workers.
      #
      # @param [Class<Worker>] worker
      #   The worker class to add.
      #
      # @return [self]
      #
      def <<(worker)
        @classes << worker
        return self
      end

      #
      # Loads a worker and adds it to the workers.
      #
      # @param [String] worker_id
      #   The worker ID to load.
      #
      # @return [self]
      #
      def load(worker_id)
        self << Recon.load_class(worker_id)
      end

      #
      # Loads a worker from a file and adds it to the workers.
      #
      # @param [String] path
      #   The path to the file.
      #
      # @return [self]
      #
      def load_file(path)
        self << Recon.load_class_from_file(path)
      end

      #
      # Removes a worker class from the workers.
      #
      # @param [Class<Worker>] worker
      #   The worker class to remove.
      #
      # @return [self, nil]
      #   If the worker class was in the workers, than `self` is returned.
      #   If the worker class was not in the workers, then `nil` will be
      #   returned.
      #
      def delete(worker)
        if @classes.delete?(worker)
          self
        end
      end

      #
      # Removes a worker with the ID from the workers.
      #
      # @param [String] worker_id
      #   The worker ID to remove.
      #
      # @return [self, nil]
      #   If the worker ID was in the workers, than `self` is returned.
      #   If the worker ID was not in the workers, then `nil` will be
      #   returned.
      #
      def remove(worker_id)
        if @classes.reject! { |worker| worker.id == worker_id }
          self
        end
      end

      # Intensity levels sorted by their intensity.
      #
      # @api private
      INTENSITY_LEVELS = [
        :passive,
        :active,
        :aggressive
      ]

      #
      # Filters the workers by their {Worker.intensity intensity} level.
      #
      # @param [:passive, :active, :aggressive] level
      #   The maximum intensity level to filter by.
      #
      # @return [Workers]
      #
      def intensity(level)
        level_index = INTENSITY_LEVELS.index(level)

        self.class.new(
          @classes.select { |worker|
            if (intensity_index = INTENSITY_LEVELS.index(worker.intensity))
              intensity_index <= level_index
            end
          }
        )
      end

      #
      # Determines if the workers is equal to another workers.
      #
      # @param [Object] other
      #   The other workers.
      #
      # @return [Boolean]
      #
      def ==(other)
        self.class == other.class &&
          @classes == other.classes
      end

      #
      # Converts the workers into a Set.
      #
      # @return [Set<Class<Worker>>]
      #
      def to_set
        @classes
      end

    end
  end
end
