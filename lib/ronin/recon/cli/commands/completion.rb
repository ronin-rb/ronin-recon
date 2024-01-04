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

require 'ronin/recon/root'
require 'ronin/core/cli/completion_command'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Manages the shell completion rules for `ronin-recon`.
        #
        # ## Usage
        #
        #     ronin-recon completion [options]
        #
        # ## Options
        #
        #         --print                      Prints the shell completion file
        #         --install                    Installs the shell completion file
        #         --uninstall                  Uninstalls the shell completion file
        #     -h, --help                       Print help information
        #
        # ## Examples
        #
        #     ronin-recon completion --print
        #     ronin-recon completion --install
        #     ronin-recon completion --uninstall
        #
        class Completion < Core::CLI::CompletionCommand

          completion_file File.join(ROOT,'data','completions','ronin-recon')

          man_dir File.join(ROOT,'man')
          man_page 'ronin-recon-completion.1'

          description 'Manages the shell completion rules for ronin-recon'

        end
      end
    end
  end
end
