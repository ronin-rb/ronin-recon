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

module Ronin
  module Recon
    module OutputFormats
      #
      # Base class for all {OutputFormats} classes.
      #
      # @abstract
      #
      class OutputFormat

        # The path to write to.
        #
        # @return [String]
        attr_reader :path

        #
        # Initializes the output file.
        #
        # @param [String] path
        #   The path to write to.
        #
        def initialize(path)
          @path = path
        end

        #
        # Writes a value to the output stream.
        #
        # @param [Values::Value] value
        #   The value to write.
        #
        # @abstract
        #
        def write_value(value)
          raise(NotImplementedError,"#{self}#<< was not implemented")
        end

        #
        # Writes a new connection between two values to the output stream.
        #
        # @param [Values::Value] value
        #   The value to write.
        #
        # @param [Values::Value] parent
        #   The parent value for the value.
        #
        # @abstract
        #
        def write_connection(value,parent)
        end

        #
        # Closes the output stream.
        #
        # @api public
        #
        # @abstract
        #
        def close
        end

      end
    end
  end
end
