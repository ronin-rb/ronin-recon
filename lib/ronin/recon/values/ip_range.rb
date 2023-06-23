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
require 'ronin/recon/values/ip'

require 'ipaddr'

module Ronin
  module Recon
    module Values
      #
      # Represents a IP CIDR range.
      #
      # @api public
      #
      class IPRange < Value

        # The IP range.
        #
        # @return [IPAddr]
        attr_reader :range

        #
        # Initializes the IP range object.
        #
        # @param [IPAddr, String] range
        #   The IP range string.
        #
        # @raise [ArgumentError]
        #   The given range was not an `IPAddr` or `String` object.
        #
        def initialize(range)
          @range = case range
                   when IPAddr then range
                   when String then IPAddr.new(range)
                   else
                     raise(ArgumentError,"IP range must be either an IPAddr or String: #{range.inspect}")
                   end
        end

        #
        # Determines if an IP address exists within the IP range.
        #
        # @param [IPAddr, String] ip
        #   The IP address to test.
        #
        # @return [Boolean]
        #   Indicates whether the IP address exists within the IP range.
        #
        def include?(ip)
          @range.include?(ip)
        end

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Imdicates whether the other value is either another {IPRange} that
        #   intersects with the IP range, or an {IP} and exists within the IP
        #   range.
        #
        def ===(other)
          case other
          when IPRange then include?(other.range)
          when IP      then include?(other.address)
          else              false
          end
        end

        #
        # Compares the value to another value.
        #
        # @param [Values::Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) && @range == other.range
        end

        #
        # The "hash" value of the IP range.
        #
        # @return [Integer]
        #   The hash value of {#range}.
        #
        def hash
          [self.class, @range].hash
        end

        #
        # Converts the IP range object to a String.
        #
        # @return [String]
        #   The IP range.
        #
        def to_s
          @range.to_s
        end

        alias to_str to_s

        #
        # Coerces the IP range value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :ip_range, range: @range.to_s}
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:ip_range]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :ip_range
        end

      end
    end
  end
end
