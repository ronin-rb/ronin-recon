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

require_relative '../command'
require_relative '../debug_option'
require_relative '../printing'
require_relative '../../value/parser'
require_relative '../../registry'
require_relative '../../engine'
require_relative '../../output_formats'

require 'ronin/db/cli/database_options'
require 'ronin/core/cli/logging'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Runs the recon engine with one or more initial values.
        #
        # ## Usage
        #
        #     ronin-recon run [options] {IP | IP-range | DOMAIN | HOST | WILDCARD | WEBSITE} ...
        #
        # ## Options
        #
        #     -D, --debug                      Enable debugging output
        #     -C, --config-file FILE           Loads the configuration file
        #     -w, --worker WORKER              Explicitly uses a worker
        #     -e, --enable WORKER              Enables a worker
        #     -d, --disable WORKER             Disables a worker
        #         --worker-file FILE           Loads a worker from a file
        #     -p, --param WORKER.NAME=VALUE    Sets a param for a worker
        #     -c, --concurrency WORKER=NUM     Sets the concurrency of a worker
        #         --max-depth NUM              The maximum recon depth (Default: 10)
        #     -o, --output FILE                The output file to write results to
        #     -I, --ignore VALUE               The values to ignore in result
        #     -F txt|list|csv|json|ndjson|dot|svg|png|pdf,
        #         --output-format              The output format
        #         --import                     Imports each newly discovered value into the Ronin database
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     IP|IP-range|DOMAIN|HOST|WILDCARD|WEBSITE  An initial recon value.
        #
        class Run < Command

          include DebugOption
          include Printing
          include Core::CLI::Logging
          include DB::CLI::DatabaseOptions

          usage '[options] {IP | IP-range | DOMAIN | HOST | WILDCARD | WEBSITE} ...'

          option :config_file, short: '-C',
                               value: {
                                 type:  String,
                                 usage: 'FILE'
                               },
                               desc: 'Loads the configuration file'

          option :worker, short: '-w',
                          value: {
                            type:  String,
                            usage: 'WORKER'
                          },
                          desc: 'Explicitly uses a worker' do |worker|
                            @only_workers << worker
                          end

          option :enable, short: '-e',
                          value: {
                            type:  String,
                            usage: 'WORKER'
                          },
                          desc: 'Enables a worker' do |worker|
                            @enable_workers << worker
                          end

          option :disable, short: '-d',
                           value: {
                             type:  String,
                             usage: 'WORKER'
                           },
                           desc: 'Disables a worker' do |worker|
                             @disable_workers << worker
                           end

          option :worker_file, value: {
                                 type:  String,
                                 usage: 'FILE'
                               },
                               desc: 'Loads a worker from a file' do |path|
                                 @worker_files << path
                               end

          option :param, short: '-p',
                         value: {
                           type:  /\A[^\.\=\s]+\.[^=\s]+=.+\z/,
                           usage: 'WORKER.NAME=VALUE'
                         },
                         desc: 'Sets a param for a worker' do |str|
                           prefix, value = str.split('=',2)
                           worker, name  = prefix.split('.',2)

                           @worker_params[worker][name.to_sym] = value
                         end

          option :concurrency, short: '-c',
                               value: {
                                 type:  /\A[^\.\=\s]+=\d+\z/,
                                 usage: 'WORKER=NUM'
                               },
                               desc: 'Sets the concurrency of a worker' do |str|
                                 worker, concurrency = str.split('=',2)

                                 @worker_concurrency[worker] = concurrency.to_i
                               end

          option :intensity, value: {
                               type: [:passive, :active, :aggressive]
                             },
                             desc: 'Filter workers by intensity'

          option :max_depth, value: {
                               type:    Integer,
                               usage:   'NUM',
                               default: 10
                             },
                             desc: 'The maximum recon depth'

          option :output, short: '-o',
                          value: {
                            type:  String,
                            usage: 'FILE'
                          },
                          desc: 'The output file to write results to' do |path|
                            options[:output]          = path
                            options[:output_format] ||= OutputFormats.infer_from(path)
                          end

          option :output_format, short: '-F',
                                 value: {
                                   type: OutputFormats.formats
                                 },
                                 desc: 'The output format'

          option :import, desc: 'Imports each newly discovered value into the Ronin database'

          option :ignore, short: '-I',
                          value: {
                            type: String,
                            usage: 'IP|IP-range|DOMAIN|HOST|WILDCARD|WEBSITE'
                          },
                          desc: 'The value to ignore in the result' do |value|
                            @ignore << Value.parse(value)
                          end

          argument :value, required: true,
                           repeats:  true,
                           usage:    'IP|IP-range|DOMAIN|HOST|WILDCARD|WEBSITE',
                           desc:     'An initial recon value'

          description 'Runs the recon engine with one or more initial values'

          man_page 'ronin-recon-run.1'

          # Explicit set of workers to only use.
          #
          # @return [Set<String>]
          attr_reader :only_workers

          # Additional set of workers to enable.
          #
          # @return [Set<String>]
          attr_reader :enable_workers

          # Additional set of workers to disable.
          #
          # @return [Set<String>]
          attr_reader :disable_workers

          # Additional set of worker files to load.
          #
          # @return [Set<String>]
          attr_reader :worker_files

          # The loaded configuration for the {Engine}.
          #
          # @return [Config]
          attr_reader :config

          # The loaded workers for the {Engine}.
          #
          # @return [Workers]
          attr_reader :workers

          # The params for the workers.
          #
          # @return [Hash{String => Hash{String => String}}]
          attr_reader :worker_params

          # The concurrency for the workers.
          #
          # @return [Hash{String => Integer}]
          attr_reader :worker_concurrency

          # The values that are out of scope.
          #
          # @return [Array<Value>]
          attr_reader :ignore

          #
          # Initializes the `ronin-recon run` command.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments.
          #
          def initialize(**kwargs)
            super(**kwargs)

            @only_workers    = Set.new
            @enable_workers  = Set.new
            @disable_workers = Set.new
            @worker_files    = Set.new

            @worker_params      = Hash.new { |hash,key| hash[key] = {} }
            @worker_concurrency = {}

            @ignore = []
          end

          #
          # Runs the `ronin-recon run` command.
          #
          # @param [Array<String>] values
          #   The initial recon values.
          #
          def run(*values)
            load_config
            load_workers

            values = values.map { |value| parse_value(value) }

            output_file = if options[:output] && options[:output_format]
                            options[:output_format].open(options[:output])
                          end

            if options[:import]
              require 'ronin/db'
              require_relative 'importer'
              db_connect
            end

            begin
              Engine.run(values, config:    @config,
                                 workers:   @workers,
                                 max_depth: options[:max_depth],
                                 ignore:    @ignore) do |engine|
                engine.on(:value) do |value,parent|
                  print_value(value,parent)
                end

                if output_file
                  engine.on(:value) do |value|
                    output_file << value
                  end

                  if output_file.kind_of?(OutputFormats::GraphFormat)
                    engine.on(:connection) do |value,parent|
                      output_file[value] = parent
                    end
                  end
                end

                if options[:import]
                  engine.on(:connection) do |value,parent|
                    import_connection(value,parent)
                  end
                end

                engine.on(:job_failed) do |worker,value,exception|
                  log_error "[#{worker.id}] job failed for value #{value}:"
                  log_error "  #{exception.class}: #{exception.message}"

                  exception.backtrace.each do |line|
                    log_error "    #{line}"
                  end
                end
              end
            ensure
              output_file.close if options[:output]
            end
          end

          #
          # Parses the value string.
          #
          # @param [String] value
          #   The value to parse.
          #
          # @return [Value]
          #   The parsed value.
          #
          def parse_value(value)
            Value.parse(value)
          rescue UnknownValue => error
            print_error(error.message)
            print_error("value must be an IP address, CIDR IP-range, domain, sub-domain, wildcard hostname, or website base URL")
            exit(-1)
          end

          #
          # Loads the recon configuration file from either
          # the `--config-file` option or `~/.config/ronin-recon/config.yml`.
          #
          def load_config
            @config = if (path = options[:config_file])
                        Config.load(path)
                      else
                        Config.default
                      end

            unless @only_workers.empty?
              @config.workers = @only_workers
            end

            @enable_workers.each do |worker_id|
              @config.workers.add(worker_id)
            end

            @disable_workers.each do |worker_id|
              @config.workers.delete(worker_id)
            end

            @worker_params.each do |worker,params|
              if @config.params.has_key?(worker)
                @config.params[worker].merge!(params)
              else
                @config.params[worker] = params
              end
            end

            @worker_concurrency.each do |worker,concurrency|
              @config.concurrency[worker] = concurrency
            end
          end

          #
          # Loads the worker classes from the {Config#workers}, as well as
          # additional workers loaded by `--load-worker`.
          #
          # @note
          #   If the `--intensity` option is given, then the workers will be
          #   filtered by intensity.
          #
          def load_workers
            @workers = Ronin::Recon::Workers.load(@config.workers)

            unless @worker_files.empty?
              @worker_files.each do |path|
                @workers.load_file(path)
              end
            end

            if (level = options[:intensity])
              @workers = @workers.intensity(level)
            end
          rescue Ronin::Recon::ClassNotFound => error
            print_error(error.message)
            exit(1)
          end

          #
          # Imports a discovered value into ronin-db.
          #
          # @param [Value] value
          #   A discovered recon value to import.
          #
          def import_value(value)
            Importer.import_value(value)
          end

          #
          # Imports a connection between two values into ronin-db.
          #
          # @param [Value] value
          #   A discovered recon value to import.
          #
          # @param [Value] parent
          #   The parent value of the discovered recon value.
          #
          def import_connection(value,parent)
            Importer.import_connection(value,parent)
          end

        end
      end
    end
  end
end
