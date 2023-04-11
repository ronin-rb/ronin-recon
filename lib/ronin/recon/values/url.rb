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

require 'ronin/recon/value'

module Ronin
  module Recon
    module Values
      #
      # Represents a discovered URL.
      #
      # @api public
      #
      class URL < Value

        # The URL string.
        #
        # @return [String]
        attr_reader :string

        #
        # Initializes the URL object.
        #
        # @param [String] string
        #
        def initialize(string)
          @string = string
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) && @string == other.string
        end

        #
        # The "hash" value of the URL.
        #
        # @return [Integer]
        #   The hash value of {#string}.
        #
        def hash
          [self.class, @string].hash
        end

        #
        # Converts the URL object to a String.
        #
        # @return [String]
        #   The URL string.
        #
        def to_s
          @string.to_s
        end

        alias to_str to_s

      end
    end
  end
end
