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
        # Initializes the IP object.
        #
        # @param [String] name
        #
        def initialize(name)
          @name = name
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          self.class == other.class && @name == other.name
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

      end
    end
  end
end
