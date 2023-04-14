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

require 'ronin/recon/cli/worker_command'
require 'ronin/recon/cli/debug_option'
require 'ronin/recon/cli/printing'

require 'ronin/core/cli/options/param'
require 'ronin/core/cli/logging'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Loads an individual worker and tests it.
        #
        # ## Usage
        #
        #     ronin-recon test [options] {--file FILE | NAME} {--domain DOMAIN | --host HOST | --ip IP | --ip-range CIDR}
        #
        # ## Options
        #
        #     -f, --file FILE                  The recon worker file to load
        #     -D, --debug                      Enable debugging output
        #     -d, --domain DOMAIN              The domain to test the recon worker with
        #     -H, --host HOST                  The host name to test the recon worker with
        #     -I, --ip IP                      The IP address to test the recon worker with
        #     -R, --ip-range CIDR              The IP range to test the recon worker with
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     [NAME]                           The recon worker to load
        #
        class Test < WorkerCommand

          include DebugOption
          include Printing
          include Core::CLI::Logging
          include Core::CLI::Options::Param

          usage '[options] {--file FILE | NAME} {--domain DOMAIN | --host HOST | --ip IP | --ip-range CIDR}'

          option :domain, short: '-d',
                          value: {
                            type:  String,
                            usage: 'DOMAIN'
                          },
                          desc: 'The domain to test the recon worker with' do |domain|
                            @value = Values::Domain.new(domain)
                          end

          option :host, short: '-H',
                        value: {
                          type:  String,
                          usage: 'HOST'
                        },
                        desc: 'The host name to test the recon worker with' do |host|
                          @value = Values::Host.new(host)
                        end

          option :ip, short: '-I',
                      value: {
                        type:  String,
                        usage: 'IP'
                      },
                      desc: 'The IP address to test the recon worker with' do |ip|
                        @value = Values::IP.new(ip)
                      end

          option :ip_range, short: '-R',
                            value: {
                              type:  String,
                              usage: 'CIDR'
                            },
                            desc: 'The IP range to test the recon worker with' do |cidr|
                              @value = Values::IPRange.new(cidr)
                            end

          description 'Loads an individual worker and tests it'

          man_page 'ronin-recon-test.1'

          # The value to test the worker with.
          #
          # @return [Value, nil]
          attr_reader :value

          #
          # Runs the `ronin-recon test` command.
          #
          # @param [String, nil] name
          #   The optional worker name to load and print metadata for.
          #
          def run(name=nil)
            super(name)

            unless @value
              print_error("must specify --domain, --host, --ip, or --ip-range")
              exit(-1)
            end

            worker_class.run(@value, params: options[:params]) do |value,parent|
              print_value(value,parent)
            end
          end

        end
      end
    end
  end
end
