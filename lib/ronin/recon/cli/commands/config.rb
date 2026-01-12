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

require_relative '../command'

require 'command_kit/commands/auto_load'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Get and set ronin-recon configuration.
        #
        # ## Usage
        #
        #     ronin-recon config [options] [COMMAND [ARGS...]]
        #
        # ## Options
        #
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     [COMMAND]                        The command name to run
        #     [ARGS ...]                       Additional arguments for the command
        #
        # ## Commands
        #
        #     disable
        #     enable
        #     get
        #     help
        #     list
        #     set
        #     unset
        #
        # ## Examples
        #
        #     ronin-recon config list
        #     ronin-recon config enable api/hunter_io
        #     ronin-recon config disable api/hunter_io
        #     ronin-recon config set --param api/hunter_io.api_key=...
        #     ronin-recon config set --concurrency web/spider=10
        #     ronin-recon config unset --param web/spider.proxy
        #     ronin-recon config unset --concurrency web/spider
        #
        # @since 0.2.0
        #
        class Config < Command

          include CommandKit::Commands::AutoLoad.new(
            dir:       "#{__dir__}/config",
            namespace: "#{self}"
          )

          examples [
            'list',
            'enable api/hunter_io',
            'disable api/hunter_io',
            'set --param api/hunter_io.api_key=...',
            'set --concurrency web/spider=10',
            'unset --param web/spider.proxy',
            'unset --concurrency web/spider'
          ]

          description 'Get and set ronin-recon configuration'

          man_page 'ronin-recon-config.1'

        end
      end
    end
  end
end
