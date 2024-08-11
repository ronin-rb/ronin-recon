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
require_relative '../../root'

require 'ronin/core/cli/generator'
require 'ronin/core/cli/generator/options/author'
require 'ronin/core/cli/generator/options/summary'
require 'ronin/core/cli/generator/options/description'
require 'ronin/core/cli/generator/options/reference'
require 'ronin/core/git'

require 'command_kit/inflector'
require 'set'

module Ronin
  module Recon
    class CLI
      module Commands
        #
        # Creates a new recon worker file.
        #
        # ## Usage
        #
        #     ronin-recon new [options] FILE
        #
        # ## Options
        #
        #     -t, --type worker|dns|web        The type for the new recon worker
        #     -a, --author NAME                The name of the author (Default: Postmodern)
        #     -e, --author-email EMAIL         The email address of the author (Default: postmodern.mod3@gmail.com)
        #     -S, --summary TEXT               One sentence summary
        #     -D, --description TEXT           A longer description
        #     -R, --reference URL              Adds a reference URL
        #     -A cert|domain|email_address|host|ip_range|ip|mailserver|nameserver|open_port|url|website|wildcard,
        #         --accepts                    The value type(s) the worker accepts
        #     -O cert|domain|email_address|host|ip_range|ip|mailserver|nameserver|open_port|url|website|wildcard,
        #         --outputs                    The value type(s) the worker outputs
        #     -I passive|active|aggressive,    Specifies the intensity of the recon worker
        #         --intensity
        #     -h, --help                       Print help information
        #
        # ## Arguments
        #
        #     PATH                             The path to the new recon workerfile
        #
        class New < Command

          include Core::CLI::Generator

          template_dir File.join(ROOT,'data','templates')

          usage '[options] FILE'

          # Mapping of recon worker types and their file/class names.
          WORKER_TYPES = {
            worker: {
              file:  'worker',
              class: 'Worker'
            },

            dns: {
              file:  'dns_worker',
              class: 'DNSWorker'
            },

            web: {
              file:  'web_worker',
              class: 'WebWorker'
            }
          }

          option :type, short: '-t',
                        value: {type: WORKER_TYPES.keys},
                        desc: 'The type for the new recon worker' do |type|
                          @worker_type = WORKER_TYPES.fetch(type)
                        end

          include Core::CLI::Generator::Options::Author
          include Core::CLI::Generator::Options::Summary
          include Core::CLI::Generator::Options::Description
          include Core::CLI::Generator::Options::Reference

          # Mapping of value types and their class names.
          VALUE_TYPES = {
            cert:          'Cert',
            domain:        'Domain',
            email_address: 'EmailAddress',
            host:          'Host',
            ip_range:      'IPRange',
            ip:            'IP',
            mailserver:    'Mailserver',
            nameserver:    'Nameserver',
            open_port:     'OpenPort',
            url:           'URL',
            website:       'Website',
            wildcard:      'Wildcard'
          }

          option :accepts, short: '-A',
                           value: {
                             type: VALUE_TYPES
                           },
                           desc: 'The value type(s) the worker accepts' do |value|
                             @accepts << value
                           end

          option :outputs, short: '-O',
                           value: {
                             type: VALUE_TYPES
                           },
                           desc: 'The value type(s) the worker outputs' do |value|
                             @outputs << value
                           end

          option :intensity, short: '-I',
                             value: {
                               type: [:passive, :active, :aggressive]
                             },
                             desc: 'Specifies the intensity of the recon worker' do |intensity|
                               @intensity = intensity
                             end

          argument :path, desc: 'The path to the new recon worker file'

          description 'Creates a new recon worker file'

          man_page 'ronin-recon-new.1'

          # The worker type information.
          #
          # @return [Hash{Symbol => String}, nil]
          attr_reader :worker_type

          # The values class names which the new worker will accept.
          #
          # @return [Set<String>]
          attr_reader :accepts

          # The values class names which the new worker will output.
          #
          # @return [Set<String>]
          attr_reader :outputs

          # The intensity level for the new worker.
          #
          # @return [:passive, :active, :aggressive, nil]
          attr_reader :intensity

          #
          # Initializes the `ronin-recon new` command.
          #
          # @param [Hash{Symbol => Object}] kwargs
          #   Additional keyword arguments.
          #
          def initialize(**kwargs)
            super(**kwargs)

            @worker_type = WORKER_TYPES.fetch(:worker)
            @accepts     = Set.new
            @outputs     = Set.new
          end

          #
          # Runs the `ronin-recon new` command.
          #
          # @param [String] file
          #   The path to the new recon worker file.
          #
          def run(file)
            @directory  = File.dirname(file)
            @file_name  = File.basename(file,File.extname(file))
            @class_name = CommandKit::Inflector.camelize(@file_name)

            mkdir @directory unless File.directory?(@directory)

            erb "worker.rb.erb", file
            chmod '+x', file
          end

        end
      end
    end
  end
end
