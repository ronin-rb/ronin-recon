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

require 'ronin/recon/cli/command'
require 'ronin/recon/cli/debug_option'
require 'ronin/recon/cli/printing'
require 'ronin/recon/value/parser'
require 'ronin/recon/registry'
require 'ronin/recon/engine'
require 'ronin/recon/output_formats'

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
        #         --max-depth NUM              The maximum recon depth (Default: 3)
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

          option :max_depth, value: {
                               type:    Integer,
                               usage:   'NUM',
                               default: 3
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

          #
          # Initializes the `ronin-recon run` command.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments.
          #
          def initialize(**kwargs)
            super(**kwargs)

            @ignore = []
          end

          #
          # Runs the `ronin-recon run` command.
          #
          # @param [Array<String>] values
          #   The initial recon values.
          #
          def run(*values)
            values = begin
                       values.map(&Value.method(:parse))
                     rescue UnknownValue => error
                       print_error(error.message)
                       print_error("value must be an IP address, CIDR IP-range, domain, sub-domain, wildcard hostname, or website base URL")
                       exit(-1)
                     end

            output_file = if options[:output] && options[:output_format]
                            options[:output_format].open(options[:output])
                          end

            if options[:import]
              require 'ronin/db'
              require 'ronin/recon/importer'
              db_connect
            end

            begin
              Engine.run(values, max_depth: options[:max_depth], ignore: @ignore) do |engine|
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
          # Imports a discovered value into ronin-db.
          #
          # @param [Values::Value] value
          #   A discovered recon value to import.
          #
          def import_value(value)
            Importer.import_value(value)
          end

          #
          # Imports a connection between two values into ronin-db.
          #
          # @param [Values::Value] value
          #   A discovered recon value to import.
          #
          # @param [Values::Value] parent
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
