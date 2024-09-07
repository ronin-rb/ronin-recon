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

require_relative '../value'
require_relative 'domain'
require_relative 'host'
require_relative 'url'

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

          @prefix, @suffix = template.split('*',2)
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) && @template == other.template
        end

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Wildcard, Domain, Host, Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Imdicates whether the other value is either a {Domain} and has the
        #   same domain name, or a {Host} and shares the same domain name.
        #
        def ===(other)
          case other
          when Wildcard
            eql?(other)
          when Domain, Host
            name = other.name

            name.start_with?(@prefix) && name.end_with?(@suffix)
          when URL
            host = other.uri.host

            host.start_with?(@prefix) && host.end_with?(@suffix)
          else
            false
          end
        end

        #
        # The "hash" value of the wildcard host name.
        #
        # @return [Integer]
        #   The hash value derived from the class and the {#template}.
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

        #
        # Returns the type or kind of recon value.
        #
        # @return [:wildcard]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :wildcard
        end

      end
    end
  end
end
