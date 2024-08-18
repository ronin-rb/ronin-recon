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

require_relative '../worker_command'
require_relative '../printing'

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

          include Printing
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

              if (outputs = worker.outputs)
                puts 'Outputs:'
                puts
                indent do
                  print_list(outputs.map(&method(:value_class_name)))
                end
                puts
              end

              puts "Intensity: #{worker.intensity}"

              print_params(worker)
            end
          end

        end
      end
    end
  end
end
