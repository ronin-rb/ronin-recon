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

require_relative 'command'
require_relative 'config_file_option'

module Ronin
  module Recon
    class CLI
      #
      # Base class for all `ronin-recon config` sub-commands.
      #
      # @since 0.2.0
      #
      class ConfigCommand < Command

        include ConfigFileOption

        #
        # Saves the configuration back out to either the `--config-file`
        # path or `~/.config/ronin-recon/config.yml`.
        #
        def save_config
          if (config_file = options[:config_file])
            @config.save(config_file)
          else
            @config.save
          end
        end

      end
    end
  end
end
