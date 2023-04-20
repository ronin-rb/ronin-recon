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
      # Represents a wildcard host-name (ex: `*.example.com`).
      #
      # @api public
      #
      class Wildcard < Value

        # The wildcard host name.
        #
        # @return [String]
        attr_reader :template

        #
        # Initializes the wildcard host object.
        #
        # @param [String] template
        #
        def initialize(template)
          @template = template
        end

        #
        # Compares the value to another value.
        #
        # @param [Values::Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) && @template == other.template
        end

        #
        # The "hash" value of the wildcard host name.
        #
        # @return [Integer]
        #   The hash value of {#template}.
        #
        def hash
          [self.class, @template].hash
        end

        #
        # Converts the wildcard host object to a String.
        #
        # @return [String]
        #   The wildcard host name.
        #
        def to_s
          @template.to_s
        end

        alias to_str to_s

        #
        # Coerces the wildcard value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :wildcard, template: @template}
        end

      end
    end
  end
end
