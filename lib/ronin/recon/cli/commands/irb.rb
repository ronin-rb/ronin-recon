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

require_relative '../command'
require_relative '../ruby_shell'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Starts an interactive Ruby shell with `ronin-recon` loaded.
        #
        # ## Usage
        #
        #     ronin-recon irb [options]
        #
        # ## Options
        #
        #     -h, --help                       Print help information
        #
        class Irb < Command

          description "Starts an interactive Ruby shell with ronin-recon loaded"

          man_page 'ronin-recon-irb.1'

          #
          # Runs the `ronin-recon irb` command.
          #
          def run
            require 'ronin/recon'
            CLI::RubyShell.start
          end

        end
      end
    end
  end
end
