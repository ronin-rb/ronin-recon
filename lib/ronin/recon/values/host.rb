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

require 'ronin/recon/value'
require 'ronin/recon/values/ip'
require 'ronin/recon/values/website'
require 'ronin/recon/values/url'

module Ronin
  module Recon
    module Values
      #
      # Represents a host-name (ex: `www.example.com`).
      #
      # @api public
      #
      class Host < Value

        # The host name.
        #
        # @return [String]
        attr_reader :name

        #
        # Initializes the host object.
        #
        # @param [String] name
        #   The host name.
        #
        def initialize(name)
          @name = name
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Indicates whether the other value is a kind of {Host} and has the
        #   same host name.
        #
        def eql?(other)
          self.class == other.class && @name == other.name
        end

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Imdicates whether the other value is either a {Host} and has the
        #   same host name, or an {IP}, {Website}, {URL} with the same host
        #   name.
        #
        def ===(other)
          case other
          when Host
            @name == other.name
          when IP, Website, URL
            @name == other.host
          else
            false
          end
        end

        #
        # The "hash" value of the host name.
        #
        # @return [Integer]
        #   The hash of the {#name}.
        #
        def hash
          [self.class, @name].hash
        end

        #
        # Converts the IP object to a String.
        #
        # @return [String]
        #   The host name.
        #
        def to_s
          @name.to_s
        end

        alias to_str to_s

        #
        # Coerces the host value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :host, name: @name}
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:host]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :host
        end

      end
    end
  end
end
