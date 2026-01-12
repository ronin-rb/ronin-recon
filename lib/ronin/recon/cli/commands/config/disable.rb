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

require_relative '../../config_command'

module Ronin
  module Recon
    class CLI
      module Commands
        class Config < Command
          #
          # Disables a worker in the configuration file.
          #
          # ## Usage
          #
          #     ronin-recon config disable [options] WORKER
          #
          # ## Options
          #
          #     -C, --config-file FILE           Loads the configuration file
          #     -h, --help                       Print help information
          #
          # ## Arguments
          #
          #     WORKER                           The worker ID to disable
          #
          # @since 0.2.0
          #
          class Disable < ConfigCommand

            argument :worker, required: true,
                              desc:     'The worker ID to disable'

            description "Disables a worker in the configuration file"

            man_page 'ronin-recon-config-disable.1'

            #
            # Runs the `ronin-recon config disable` command.
            #
            # @param [String] worker
            #   The worker ID to disable.
            #
            def run(worker)
              load_config

              @config.workers.delete(worker)

              save_config
            end

          end
        end
      end
    end
  end
end
