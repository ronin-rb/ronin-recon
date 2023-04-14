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

require 'ronin/recon/cli/command'
require 'ronin/recon/cli/debug_option'
require 'ronin/recon/cli/printing'
require 'ronin/recon/registry'
require 'ronin/recon/engine'

require 'ronin/db/cli/database_options'
require 'ronin/core/cli/logging'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Runs the recon engine with one or more initial values.
        #
        # ## Usage
        #
        #     ronin-recon run [options] {--domain DOMAIN | --host HOST | --ip IP | --ip-range CIDR} ...
        #
        # ## Options
        #
        #     -D, --debug                      Enable debugging output
        #         --max-depth NUM              The maximum recon depth (Default: 3)
        #     -d, --domain DOMAIN              The domain to start reconning
        #     -H, --host HOST                  The host name to start reconning
        #     -I, --ip IP                      The IP address to start reconning
        #     -R, --ip-range CIDR              The IP range to start reconning
        #         --import                     Imports each newly discovered value into the Ronin database
        #     -h, --help                       Print help information
        #
        class Run < Command

          include DebugOption
          include Printing
          include Core::CLI::Logging
          include DB::CLI::DatabaseOptions

          usage '[options] {--domain DOMAIN | --host HOST | --ip IP | --ip-range CIDR} ...'

          option :max_depth, value: {
                               type:    Integer,
                               usage:   'NUM',
                               default: 3
                             },
                             desc: 'The maximum recon depth'

          option :domain, short: '-d',
                          value: {
                            type:  String,
                            usage: 'DOMAIN'
                          },
                          desc: 'The domain to start reconning' do |domain|
                            @values << Values::Domain.new(domain)
                          end

          option :host, short: '-H',
                        value: {
                          type:  String,
                          usage: 'HOST'
                        },
                        desc: 'The host name to start reconning' do |host|
                          @values << Values::Host.new(host)
                        end

          option :ip, short: '-I',
                      value: {
                        type:  String,
                        usage: 'IP'
                      },
                      desc: 'The IP address to start reconning' do |ip|
                        @values << Values::IP.new(ip)
                      end

          option :ip_range, short: '-R',
                            value: {
                              type:  String,
                              usage: 'CIDR'
                            },
                            desc: 'The IP range to start reconning' do |cidr|
                              @values << Values::IPRange.new(cidr)
                            end

          option :import, desc: 'Imports each newly discovered value into the Ronin database'

          description 'Runs the recon engine with one or more initial values'

          man_page 'ronin-recon-run.1'

          # The initial values to start reconning.
          #
          # @return [Array<Value>]
          attr_reader :values

          #
          # Initializes the command.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments for the command.
          #
          def initialize(**kwargs)
            super(**kwargs)

            @values = []
          end

          #
          # Runs the `ronin-recon run` command.
          #
          def run
            if @values.empty?
              print_error("must specify --domain, --host, --ip, or --ip-range")
              exit(-1)
            end

            if options[:import]
              require 'ronin/db'
              require 'ronin/recon/importer'
              db_connect
            end

            engine = Engine.run(@values, max_depth: options[:max_depth]) do |value,parent|
              print_value(value,parent)

              import_value(value) if options[:import]
            end
          end

          def import_value(value)
            Importer.import_value(value)
          end

        end
      end
    end
  end
end
