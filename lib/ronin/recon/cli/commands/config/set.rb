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
          # Sets the concurrency or a param for a worker.
          #
          # ## Usage
          #
          #     ronin-recon config set [options]
          #
          # ## Options
          #
          #     -C, --config-file FILE           Loads the configuration file
          #     -c, --concurrency WORKER=NUM     Sets the concurrency of a worker
          #     -p, --param WORKER.NAME=VALUE    Sets a param for a worker
          #     -h, --help                       Print help information
          #
          # @since 0.2.0
          #
          class Set < ConfigCommand

            option :concurrency, short: '-c',
                                 value: {
                                   type:  /\A([^\.\=\s]+)=(\d+)\z/,
                                   usage: 'WORKER=NUM'
                                 },
                                 desc: 'Gets the concurrency for the worker' do |str,worker,concurrency|
                                   @mode        = :concurrency
                                   @worker      = worker
                                   @concurrency = concurrency.to_i
                                 end

            option :param, short: '-p',
                           value: {
                             type:  /\A([^\.\=\s]+)\.([^=\s]+)=(.+)\z/,
                             usage: 'WORKER.NAME=VALUE'
                           },
                           desc: 'Gets the param for the worker' do |str,worker,param_name,param_value|
                             @mode        = :param
                             @worker      = worker
                             @param_name  = param_name.to_sym
                             @param_value = param_value
                           end

            description "Sets the concurrency or a param for a worker"

            man_page 'ronin-recon-config-set.1'

            # The worker name.
            #
            # @return [String, nil]
            attr_reader :worker

            # The concurrency value to set.
            #
            # @return [Integer, nil]
            attr_reader :concurrency

            # The param name to set.
            #
            # @return [Symbol, nil]
            attr_reader :param_name

            # The param value to set.
            #
            # @return [String, nil]
            attr_reader :param_value

            #
            # Runs the `ronin-recon config set` command.
            #
            def run
              load_config

              if @concurrency
                @config.concurrency[@worker] = @concurrency
              elsif @param_name
                if (params = @config.params[@worker])
                  params[@param_name] = @param_value
                else
                  @config.params[@worker] = {@param_name => @param_value}
                end
              else
                print_error "--concurrency or --param options must be given"
                exit(-1)
              end

              save_config
            end

          end
        end
      end
    end
  end
end
