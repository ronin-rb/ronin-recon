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

require 'ronin/recon/registry'
require 'ronin/core/params/exceptions'

module Ronin
  module Recon
    class CLI
      #
      # Helper methods for loading worker classes from within CLI commands.
      #
      module WorkerMethods
        #
        # Loads a recon worker class.
        #
        # @param [String] name
        #   The worker name to load.
        #
        # @return [Class<Worker>]
        #   The loaded recon worker class.
        #
        def load_worker(name)
          Recon.load_class(name)
        rescue Recon::ClassNotFound => error
          print_error(error.message)
          exit(1)
        rescue => error
          print_exception(error)
          print_error("an unhandled exception occurred while loading worker #{name}")
          exit(-1)
        end

        #
        # Loads the recon worker class from a given file.
        #
        # @param [String] file
        #   The file to load the worker class from.
        #
        # @return [Class<Worker>]
        #   The loaded recon worker class.
        #
        def load_worker_from(file)
          Recon.load_class_from_file(file)
        rescue Recon::ClassNotFound => error
          print_error(error.message)
          exit(1)
        rescue => error
          print_exception(error)
          print_error("an unhandled exception occurred while loading recon worker from file #{file}")
          exit(-1)
        end
      end
    end
  end
end
