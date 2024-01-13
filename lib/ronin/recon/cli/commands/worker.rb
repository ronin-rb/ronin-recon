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
require 'ronin/recon/cli/printing'
require 'ronin/core/cli/printing/metadata'
require 'ronin/core/cli/printing/params'

require 'command_kit/printing/lists'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Prints information about a recon worker.
        #
        # ## Usage
        #
        #     ronin-recon worker [options] {--file FILE | NAME}
        #
        # ## Options
        #
        #     -f, --file FILE                  The recon worker file to load
        #     -v, --verbose                    Enables verbose output
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     [NAME]                           The recon worker to load
        #
        class Worker < WorkerCommand

          include Core::CLI::Printing::Metadata
          include Core::CLI::Printing::Params
          include CommandKit::Printing::Lists

          usage '[options] {--file FILE | NAME}'

          description 'Prints information about a recon worker'

          man_page 'ronin-recon-worker.1'

          #
          # Runs the `ronin-recon worker` command.
          #
          # @param [String, nil] name
          #   The optional worker name to load and print metadata for.
          #
          def run(name=nil)
            super(name)

            print_worker(worker_class)
          end

          #
          # Prints the metadata for a recon worker class.
          #
          # @param [Class<Ronin::Recon::Worker>] worker
          #   The worker class to print metadata for.
          #
          def print_worker(worker)
            puts "[ #{worker.id} ]"
            puts

            indent do
              puts "Summary: #{worker.summary}" if worker.summary

              print_authors(worker)
              print_description(worker)

              puts 'Accepts:'
              puts
              indent do
                print_list(worker.accepts.map(&method(:value_class_name)))
              end
              puts

              puts 'Outputs:'
              puts
              indent do
                print_list(worker.outputs.map(&method(:value_class_name)))
              end
              puts

              print_params(worker)
            end
          end

          VALUE_CLASS_NAMES = {
            Values::Domain       => 'domains',
            Values::Host         => 'hosts',
            Values::IP           => 'IP addresses',
            Values::IPRange      => 'IP ranges',
            Values::Mailserver   => 'mailservers',
            Values::Nameserver   => 'nameservers',
            Values::OpenPort     => 'open ports',
            Values::EmailAddress => 'email addresses',
            Values::URL          => 'URLs',
            Values::Website      => 'websites',
            Values::Wildcard     => 'wildcard host names'
          }

          #
          # Converts the value class into a printable name.
          #
          # @param [Class<Value>] value_class
          #   The value class.
          #
          # @return [String]
          #   The descriptive name for the value class.
          #
          # @raise [NotImplementedError]
          #
          def value_class_name(value_class)
            VALUE_CLASS_NAMES.fetch(value_class) do
              raise(NotImplementedError,"unknown value class: #{value_class.inspect}")
            end
          end

        end
      end
    end
  end
end
