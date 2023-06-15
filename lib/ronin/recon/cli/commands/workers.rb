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
require 'ronin/recon/registry'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Lists the available recon workers.
        #
        # ## Usage
        #
        #    ronin-recon help [options]
        #
        # ## Options
        #
        #    -h, --help                       Print help information
        #
        # ## Arguments
        #
        #    [COMMAND]                        Command name to lookup
        #
        class Workers < Command

          usage '[options] [DIR]'

          argument :dir, required: false,
                         desc:     'The optional recon worker directory to list'

          description 'Lists the available recon workers'

          man_page 'ronin-workers-list.1'

          #
          # Runs the `ronin-recon workers` command.
          #
          # @param [String, nil] dir
          #   The optional recon worker directory to list.
          #
          def run(dir=nil)
            files = if dir
                      dir = "#{dir}/" unless dir.end_with?('/')

                      Ronin::Recon.list_files.select do |file|
                        file.start_with?(dir)
                      end
                    else
                      Ronin::Recon.list_files
                    end

            files.each do |file|
              puts "  #{file}"
            end
          end

        end
      end
    end
  end
end
