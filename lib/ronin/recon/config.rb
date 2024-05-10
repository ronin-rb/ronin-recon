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

require 'ronin/recon/exceptions'

require 'ronin/core/home'
require 'set'

module Ronin
  module Recon
    #
    # Represents configuration for the recon engine.
    #
    class Config

      #
      # Represents the set of workers to use.
      #
      # @api private
      #
      class Workers

        include Enumerable

        # The set of worker IDs.
        #
        # @return [Set<String>]
        attr_reader :ids

        #
        # Initializes the workers.
        #
        # @param [Set<String>, Array<String>, Hash{String => Boolean}] workers
        #   The set of worker IDs.
        #
        # @raise [ArgumentError]
        #   The given workers argument was not a Set, Array, or Hash.
        #
        def initialize(workers)
          case workers
          when Set   then @ids = workers.dup
          when Array then @ids = workers.to_set
          when Hash
            @ids = DEFAULT.dup

            workers.each do |worker_id,enabled|
              if enabled then add(worker_id)
              else            delete(worker_id)
              end
            end
          else
            raise(ArgumentError,"workers value must be a Set, Array, or Hash: #{workers.inspect}")
          end
        end

        # The default workers configuration.
        DEFAULT = Set[
          'dns/lookup',
          'dns/mailservers',
          'dns/nameservers',
          'dns/reverse_lookup',
          'dns/srv_enum',
          'dns/subdomain_enum',
          'dns/suffix_enum',
          'net/ip_range_enum',
          'net/port_scan',
          'net/service_id',
          'ssl/cert_grab',
          'ssl/cert_enum',
          # NOTE: disabled due to rate limiting issues
          # 'ssl/cert_sh',
          'web/dir_enum',
          'web/email_addresses',
          'web/spider'
        ]

        #
        # Initializes the default workers.
        #
        # @return [Workers]
        #
        def self.default
          new(DEFAULT)
        end

        #
        # Adds a worker to the workers.
        #
        # @param [String] worker_id
        #   The worker ID to add.
        #
        # @return [self]
        #
        # @api public
        #
        def add(worker_id)
          @ids.add(worker_id)
          return self
        end

        #
        # Deletes a worker from the workers.
        #
        # @param [String] worker_id
        #   The worker ID to disable.
        #
        # @api public
        #
        def delete(worker_id)
          @ids.delete(worker_id)
          return self
        end

        #
        # Determines if the worker is enabled in the workers.
        #
        # @param [String] worker_id
        #   The worker ID to search for.
        #
        # @return [Boolean]
        #
        # @api public
        #
        def include?(worker_id)
          @ids.include?(worker_id)
        end

        #
        # Enumerates over each worker in the set.
        #
        # @yield [worker_id]
        #   The given block will be passed each worker ID in the set.
        #
        # @yieldparam [String] worker_id
        #   A worker ID in the set.
        #
        # @return [Enumerator]
        #   If no block is given, an Enumerator will be returned.
        #
        def each(&block)
          @ids.each(&block)
        end

        #
        # Compares the workers to another object.
        #
        # @param [Object] other
        #   The other object.
        #
        # @return [Boolean]
        #
        def eql?(other)
          self.class == other.class && @ids == other.ids
        end

        alias == eql?

      end

      # The workers to use.
      #
      # @return [Workers]
      #
      # @api public
      attr_reader :workers

      # Params for individual workers.
      #
      # @return [Hash{String => Hash{Symbol => Object}}]
      #
      # @api public
      attr_reader :params

      # Concurrency values for individual workers.
      #
      # @return [Hash{String => Integer}]
      #
      # @api public
      attr_reader :concurrency

      #
      # Initializes the recon engine configuration.
      #
      # @param [Workers] workers
      #   The workers to use.
      #
      # @param [Hash{String => Hash{Symbol => Object}}] params
      #   The params for individual workers.
      #
      # @param [Hash{String => Hash{Symbol => Object}}] concurrency
      #   The concurrency values for individual workers.
      #
      def initialize(workers: Workers.default, params: {}, concurrency: {})
        @workers     = workers
        @params      = params
        @concurrency = concurrency
      end

      #
      # Validates the loaded configuration data.
      #
      # @param [Object] data
      #   The loaded configuration data.
      #
      # @raise [InvalidConfig]
      #   The configuration data is not a Hash, does not contain Symbol keys,
      #   or does not contain Hashes.
      #
      # @return [true]
      #   The configuration data is valid.
      #
      def self.validate(data)
        unless data.kind_of?(Hash)
          raise(InvalidConfig,"must contain a Hash: #{data.inspect}")
        end

        if (workers = data[:workers])
          unless (workers.kind_of?(Hash) || workers.kind_of?(Array))
            raise(InvalidConfig,"workers value must be a Hash or an Array: #{workers.inspect}")
          end
        end

        if (params_value = data[:params])
          unless params_value.kind_of?(Hash)
            raise(InvalidConfig,"params value must be a Hash: #{params_value.inspect}")
          end

          params_value.each do |worker_id,params_hash|
            unless worker_id.kind_of?(String)
              raise(InvalidConfig,"worker ID must be a String: #{worker_id.inspect}")
            end

            unless params_hash.kind_of?(Hash)
              raise(InvalidConfig,"params value for worker (#{worker_id.inspect}) must be a Hash: #{params_hash.inspect}")
            end

            params_hash.each_key do |param_key|
              unless param_key.kind_of?(Symbol)
                raise(InvalidConfig,"param key for worker (#{worker_id.inspect}) must be a Symbol: #{param_key.inspect}")
              end
            end
          end
        end

        if (concurrency_value = data[:concurrency])
          unless concurrency_value.kind_of?(Hash)
            raise(InvalidConfig,"concurrency value must be a Hash: #{concurrency_value.inspect}")
          end

          concurrency_value.each do |worker_id,concurrency|
            unless worker_id.kind_of?(String)
              raise(InvalidConfig,"worker ID must be a String: #{worker_id.inspect}")
            end

            unless concurrency.kind_of?(Integer)
              raise(InvalidConfig,"concurrency value for worker (#{worker_id.inspect}) must be an Integer: #{concurrency.inspect}")
            end
          end
        end

        return true
      end

      #
      # Loads configuration from a YAML file.
      #
      # @param [String] path
      #   The path to the YAML configuration file.
      #
      # @raise [InvalidConfigFile]
      #   The configuration file contained invalid YAML.
      #
      def self.load(path)
        yaml = YAML.load_file(path)

        begin
          validate(yaml)
        rescue InvalidConfig => error
          raise(InvalidConfigFile,"invalid config file (#{path.inspect}): #{error.message}")
        end

        workers = if (workers_value = yaml[:workers])
                    Workers.new(workers_value)
                  else
                    Workers.default
                  end

        params      = yaml.fetch(:params,{})
        concurrency = yaml.fetch(:concurrency,{})

        return new(workers: workers, params: params, concurrency: concurrency)
      end

      # The path to the `~/.config/ronin-recon/config.yml` file.
      DEFAULT_PATH = File.join(Core::Home.config_dir('ronin-recon'),'config.yml')

      #
      # The default configuration to use.
      #
      # @return [Config]
      #
      # @api public
      #
      def self.default
        if File.file?(DEFAULT_PATH)
          load(DEFAULT_PATH)
        else
          new
        end
      end

      #
      # Overrides the workers.
      #
      # @param [Workers, Set<String>, Array<String>] new_workers
      #   The new workers value.
      #
      # @return [Workers]
      #   The new workers value.
      #
      # @raise [ArgumentError]
      #   An invalid workers value was given.
      #
      # @api public
      #
      def workers=(new_workers)
        @workers = case new_workers
                   when Workers          then new_workers
                   when Set, Array, Hash then Workers.new(new_workers)
                   else
                     raise(ArgumentError,"new workers value must be a #{Workers}, Set, Array, or Hash: #{new_workers.inspect}")
                   end
      end

      #
      # Compares the configuration with another object.
      #
      # @param [Object] other
      #   The other object.
      #
      # @return [Boolean]
      #
      def eql?(other)
        self.class == other.class &&
          @workers     == other.workers &&
          @params      == other.params &&
          @concurrency == other.concurrency
      end

      alias == eql?

    end
  end
end
