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

require 'ronin/recon/registry'

require 'set'

module Ronin
  module Recon
    #
    # Represents a set of recon workers.
    #
    # @api semipublic
    #
    class WorkerSet

      include Enumerable

      # The workers in the set.
      #
      # @return [Set<Class<Worker>>]
      attr_reader :workers

      #
      # Initializes the worker set.
      #
      # @param [Array<Class<Worker>>] workers
      #   The array of worker classes.
      #
      def initialize(workers=Set.new)
        @workers = workers.to_set
      end

      #
      # Loads the worker classes.
      #
      # @param [Array<String>] worker_ids
      #   The array of worker IDs to load.
      #
      # @return [WorkerSet]
      #
      def self.load(worker_ids)
        worker_set = new

        worker_ids.each do |worker_id|
          worker_set.load(worker_id)
        end

        return worker_set
      end

      #
      # Alias for {load}.
      #
      # @param [Array<String>] worker_ids
      #   The array of worker IDs to load.
      #
      # @return [WorkerSet]
      #
      def self.[](*worker_ids)
        load(worker_ids)
      end

      # The default set of workers to load.
      #
      # @api private
      DEFAULT_SET = %w[
        dns/lookup
        dns/mailservers
        dns/nameservers
        dns/subdomain_enum
        dns/suffix_enum
        dns/srv_enum
        net/ip_range_enum
        net/port_scan
        net/service_id
        ssl/cert_grab
        ssl/cert_enum
        web/spider
        web/dir_enum
      ]

      #
      # Loads the default set of workers.
      #
      # * {DNS::Lookup dns/lookup}
      # * {DNS::Mailservers dns/mailservers}
      # * {DNS::Nameservers dns/nameservers}
      # * {DNS::SubdomainEnum dns/subdomain_enum}
      # * {DNS::SuffixEnum dns/suffix_enum}
      # * {DNS::SRVEnum dns/srv_enum}
      # * {Net::IPRangeEnum net/ip_range_enum}
      # * {Net::PortScan net/port_scan}
      # * {Net::ServiceID net/service_id}
      # * {SSL::CertGrab ssl/cert_grab}
      # * {SSL::CertEnum ssl/cert_enum}
      # * {Web::Spider web/spider}
      # * {Web::DirEnum web/dir_enum}
      #
      # @return [WorkerSet]
      #
      def self.default
        load(DEFAULT_SET)
      end

      #
      # Loads all workers.
      #
      # @return [WorkerSet]
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
      # @return [WorkerSet]
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
        @workers.each(&block)
      end

      #
      # Adds another set of workers to the worker set.
      #
      # @param [WorkerSet, Array<Class<Worker>>] other
      #
      # @return [WorkerSet]
      #
      def +(other)
        other_workers = other.to_set

        self.class.new((@workers + other_workers).uniq)
      end

      #
      # Adds the worker class to the worker set.
      #
      # @param [Class<Worker>] worker
      #   The worker class to add.
      #
      # @return [self]
      #
      def <<(worker)
        @workers << worker
        return self
      end

      #
      # Loads a worker and adds it to the worker set.
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
      # Loads a worker from a file and adds it to the worker set.
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
      # Removes a worker class from the worker set.
      #
      # @param [Class<Worker>] worker
      #   The worker class to remove.
      #
      # @return [self, nil]
      #   If the worker class was in the worker set, than `self` is returned.
      #   If the worker class was not in the worker set, then `nil` will be
      #   returned.
      #
      def delete(worker)
        if @workers.delete?(worker)
          self
        end
      end

      #
      # Removes a worker with the ID from the worker set.
      #
      # @param [String] worker_id
      #   The worker ID to remove.
      #
      # @return [self, nil]
      #   If the worker ID was in the worker set, than `self` is returned.
      #   If the worker ID was not in the worker set, then `nil` will be
      #   returned.
      #
      def remove(worker_id)
        if @workers.reject! { |worker| worker.id == worker_id }
          self
        end
      end

      # Intensity levels sorted by their intensity.
      #
      # @api private
      INTENSITY_LEVELS = [
        :passive,
        :active,
        :intense
      ]

      #
      # Filters the workers by their {Worker.intensity intensity} level.
      #
      # @param [:passive, :active, :intensive] level
      #   The maximum intensity level to filter by.
      #
      # @return [WorkerSet]
      #
      def intensity(level)
        level_index = INTENSITY_LEVELS.index(level)

        self.class.new(
          @workers.select { |worker|
            if (intensity_index = INTENSITY_LEVELS.index(worker.intensity))
              intensity_index <= level_index
            end
          }
        )
      end

      #
      # Converts the worker set into a Set.
      #
      # @return [Set<Class<Worker>>]
      #
      def to_set
        @workers
      end

    end
  end
end
