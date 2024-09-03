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
          # Unsets the concurrency or params for a worker.
          #
          # ## Usage
          #
          #     ronin-recon config unset [options] {--concurrency WORKER | --param WORKER.NAME}
          #
          # ## Options
          #
          #     -C, --config-file FILE           Loads the configuration file
          #     -c, --concurrency WORKER         Gets the concurrency of a worker
          #     -p, --param WORKER.PARAM         Gets a param for a worker
          #     -h, --help                       Print help information
          #
          # @since 0.2.0
          #
          class Unset < ConfigCommand

            usage '[options] {--concurrency WORKER | --param WORKER.NAME}'

            option :concurrency, short: '-c',
                                 value: {
                                   type:  String,
                                   usage: 'WORKER'
                                 },
                                 desc: 'Gets the concurrency for the worker' do |worker|
                                   @mode   = :concurrency
                                   @worker = worker
                                 end

            option :param, short: '-p',
                           value: {
                             type:  /\A([^\.\=\s]+)\.([^=\s]+)\z/,
                             usage: 'WORKER.PARAM'
                           },
                           desc: 'Gets the param for the worker' do |str,worker,param|
                             @mode   = :param
                             @worker = worker
                             @param  = param.to_sym
                           end

            description 'Unsets the concurrency or params for a worker'

            man_page 'ronin-recon-config-unset.1'

            # Specifies whether to unset the worker's concurrency or param.
            #
            # @return [:concurrency, :param, nil]
            attr_reader :mode

            # The worker name.
            #
            # @return [String, nil]
            attr_reader :worker

            # The param name to unset.
            #
            # @return [String, nil]
            attr_reader :param

            #
            # Runs the `ronin-recon config unset` command.
            #
            def run
              load_config

              case @mode
              when :concurrency
                @config.concurrency.delete(@worker)
              when :param
                if (params = @config.params[@worker])
                  params.delete(@param)
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
