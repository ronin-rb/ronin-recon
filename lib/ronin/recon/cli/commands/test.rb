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

require 'ronin/recon/cli/worker_command'
require 'ronin/recon/cli/debug_option'
require 'ronin/recon/cli/printing'
require 'ronin/recon/value/parser'

require 'ronin/core/cli/options/param'
require 'ronin/core/cli/logging'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Loads an individual worker and tests it.
        #
        # ## Usage
        #
        #     ronin-recon test [options] {--file FILE | NAME} {IP | IP-range | DOMAIN | HOST | WILDCARD | WEBSITE}
        #
        # ## Options
        #
        #     -f, --file FILE                  The recon worker file to load
        #     -D, --debug                      Enable debugging output
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     IP|IP-range|DOMAIN|HOST|WILDCARD|WEBSITE  An initial recon value.
        #
        class Test < WorkerCommand

          include DebugOption
          include Printing
          include Core::CLI::Logging
          include Core::CLI::Options::Param

          usage '[options] {IP | IP-range | DOMAIN | HOST | WILDCARD | WEBSITE}'

          argument :value, required: true,
                           usage:    'IP|IP-range|DOMAIN|HOST|WILDCARD|WEBSITE',
                           desc:     'The initial recon value'

          description 'Loads an individual worker and tests it'

          man_page 'ronin-recon-test.1'

          #
          # Runs the `ronin-recon test` command.
          #
          # @param [String, nil] name
          #   The optional worker name to load and print metadata for.
          #
          def run(name=nil,value)
            super(name)

            value = begin
                      Value.parse(value)
                    rescue UnknownValue => error
                      print_error(error.message)
                      print_error("must be a #{worker_class.accepts.map(&method(:value_class_name)).join(', ')} value")
                      exit(-1)
                    end

            unless worker_class.accepts.include?(value.class)
              print_error "worker #{worker_class.id.inspect} does not accept #{value_class_name(value.class)} values"
              print_error "must be a #{worker_class.accepts.map(&method(:value_class_name)).join(', ')} value"
              exit(1)
            end

            worker_class.run(value, params: params) do |new_value|
              print_value(new_value)
            end
          end

        end
      end
    end
  end
end
