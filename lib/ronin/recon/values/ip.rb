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

require 'ronin/recon/values/value'

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

        # The optional parent host name.
        #
        # @return [String, nil]
        attr_reader :host

        #
        # Initializes the IP object.
        #
        # @param [String] address
        #   The IP address.
        #
        def initialize(address, host: nil)
          @address = address
          @host    = host
        end

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Indicates whether the other value is a kind of {IP} and has the
        #   same address.
        #
        def ===(other)
          self.class == other.class && @address == other.address
        end

        #
        # Compares the value to another value.
        #
        # @param [Values::Value] other
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

        #
        # Coerces the IP value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :ip, address: @address}
        end

      end
    end
  end
end
