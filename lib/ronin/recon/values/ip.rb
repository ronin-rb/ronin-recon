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
      # Represents an IP address.
      #
      # @api public
      #
      class IP < Value

        # The IP address.
        #
        # @return [String]
        attr_reader :address

        #
        # Initializes the IP object.
        #
        # @param [String] address
        #   The IP address.
        #
        def initialize(address)
          @address = address
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) && @address == other.address
        end

        #
        # The "hash" value for the IP address.
        #
        # @return [Integer]
        #   The hash of the {#address}.
        #
        def hash
          [self.class, @address].hash
        end

        #
        # Converts the IP object to a String.
        #
        # @return [String]
        #   The IP address.
        #
        def to_s
          @address.to_s
        end

        alias to_str to_s

      end
    end
  end
end
