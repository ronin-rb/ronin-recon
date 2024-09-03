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

require_relative '../../config_command'

module Ronin
  module Recon
    class CLI
      module Commands
        class Config < Command
          #
          # Lists the values in the configuration file.
          #
          # ## Usage
          #
          #     ronin-recon config list [options]
          #
          # ## Options
          #
          #     -C, --config-file FILE           Loads the configuration file
          #     -h, --help                       Print help information
          #
          # @since 0.2.0
          #
          class List < ConfigCommand

            description "Lists the values in the configuration file"

            man_page 'ronin-recon-config-list.1'

            #
            # Runs the `ronin-recon config list` command.
            #
            def run
              load_config

              puts "Workers:"
              @config.workers.each do |worker_id|
                puts " * #{worker_id}"
              end

              unless @config.concurrency.empty?
                puts
                puts "Concurrency:"
                @config.concurrency.each do |worker_id,concurrency|
                  puts " * #{worker_id}=#{concurrency}"
                end
              end

              unless @config.params.empty?
                puts
                puts "Params:"
                @config.params.each do |worker_id,params|
                  puts " * #{worker_id}"

                  params.each do |name,value|
                    puts "   * #{name}=#{value}"
                  end
                end
              end
            end

          end
        end
      end
    end
  end
end
