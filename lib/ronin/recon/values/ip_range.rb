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
      # Represents a IP CIDR range.
      #
      # @api public
      #
      class IPRange < Value

        # The IP range.
        #
        # @return [String]
        attr_reader :range

        #
        # Initializes the IP range object.
        #
        # @param [String] range
        #   The IP range string.
        #
        def initialize(range)
          @range = range
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
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
          {type: :ip_range, range: @range}
        end

      end
    end
  end
end
