# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)
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
        #     -d, --domain DOMAIN              The domain to start reconning
        #     -H, --host HOST                  The host name to start reconning
        #     -I, --ip IP                      The IP address to start reconning
        #     -R, --ip-range CIDR              The IP range to start reconning
        #     -o, --output FILE                The output file to write results to
        #     -F txt|list|csv|json|ndjson|dot, The output format
        #         --output-format
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

          argument :value, required: true,
                           repeats:  true,
                           usage:    'IP|IP-range|DOMAIN|HOST|WILDCARD|WEBSITE',
                           desc:     'An initial recon value'

          description 'Runs the recon engine with one or more initial values'

          man_page 'ronin-recon-run.1'

          #
          # Runs the `ronin-recon run` command.
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
              engine = Engine.run(values, max_depth: options[:max_depth]) do |engine|
                engine.on(:value) do |value,parent|
                  print_value(value,parent)

                  output_file << value if options[:output]
                  import_value(value)  if options[:import]
                end

                if output_file.kind_of?(OutputFormats::GraphFormat)
                  engine.on(:connection) do |value,parent|
                    output_file[value] = parent
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

          def import_value(value)
            Importer.import_value(value)
          end

        end
      end
    end
  end
end
