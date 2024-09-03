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

require_relative '../config'

module Ronin
  module Recon
    class CLI
      #
      # Defines the `-C, --config-file` option.
      #
      # @since 0.2.0
      #
      module ConfigFileOption
        #
        # Defines the `-C, --config-file` option on the command class that
        # included {ConfigFileOption}.
        #
        # @param [Class] command
        #   The command class that included {ConfigFileOption}.
        #
        def self.included(command)
          command.option :config_file, short: '-C',
                                       value: {
                                         type:  String,
                                         usage: 'FILE'
                                       },
                                       desc: 'Loads the configuration file'
        end

        # The loaded configuration for the {Engine}.
        #
        # @return [Config]
        attr_reader :config

        #
        # Loads the recon configuration file from either
        # the `--config-file` option or `~/.config/ronin-recon/config.yml`.
        #
        # @note
        #   * If the `--config-file` path is missing an error will be printed
        #     and the command will exit with -1.
        #   * If the config file is invalid an error will be printed and the
        #     command will exit with -2.
        #
        def load_config
          @config = begin
                      if (path = options[:config_file])
                        unless File.file?(path)
                          print_error("no such file or directory: #{path}")
                          exit(-1)
                        end

                        Config.load(path)
                      else
                        Config.default
                      end
                    rescue InvalidConfigFile => error
                      print_error(error.message)
                      exit(-2)
                    end
        end
      end
    end
  end
end
