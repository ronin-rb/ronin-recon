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

require 'console'

module Ronin
  module Recon
    class CLI
      #
      # Adds a `-D,--debug` option to the command that enables debugging output.
      #
      module DebugOption
        #
        # Adds the `-D,--debug` option to the including command class.
        #
        # @param [Class<Command>] command
        #   The command class which is including {DebugOption}.
        #
        def self.included(command)
          command.option :debug, short: '-D',
                                 desc:  'Enable debugging output' do
                                   Console.logger.level = Console::Logger::DEBUG
                                 end
        end
      end
    end
  end
end
