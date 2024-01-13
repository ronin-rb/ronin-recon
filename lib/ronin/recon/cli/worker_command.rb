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

require 'ronin/recon/cli/command'
require 'ronin/recon/cli/worker_methods'

module Ronin
  module Recon
    class CLI
      #
      # Base class for commands which load an individual worker.
      #
      class WorkerCommand < Command

        include WorkerMethods

        usage '[options] {--file FILE | NAME}'

        option :file, short: '-f',
                      value: {
                        type:  String,
                        usage: 'FILE'
                      },
                      desc: 'The recon worker file to load'

        argument :name, required: false,
                        desc:     'The recon worker to load'

        # The loaded worker class.
        #
        # @return [Class<Worker>, nil]
        attr_reader :worker_class

        #
        # Loads the recon worker class.
        #
        # @param [String, nil] name
        #   The optional recon worker name to load.
        #
        # @return [Class<Worker>]
        #   The loaded recon worker class.
        #
        def run(name=nil)
          if name              then load_worker(name)
          elsif options[:file] then load_worker_from(options[:file])
          else
            print_error("must specify --file or a NAME")
            exit(-1)
          end
        end

        #
        # Loads the recon worker class and sets {#worker_class}.
        #
        # @param [String] id
        #   The recon worker name to load.
        #
        def load_worker(id)
          @worker_class = super(id)
        end

        #
        # Loads the recon worker class from the given file and sets
        # {#worker_class}.
        #
        # @param [String] file
        #   The file to load the recon worker class from.
        #
        def load_worker_from(file)
          @worker_class = super(file)
        end

      end
    end
  end
end
