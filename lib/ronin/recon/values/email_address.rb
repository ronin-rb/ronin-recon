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

module Ronin
  module Recon
    module Values
      #
      # Represents an email address.
      #
      # @api public
      #
      class EmailAddress < Value

        # The email address.
        #
        # @return [String]
        attr_reader :address

        #
        # Initializes the email address object.
        #
        # @param [String] address
        #   The email address.
        #
        def initialize(address)
          @address = address
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Indicates whether the other value is a kind of {EmailAddress} and
        #   has the same address.
        #
        def eql?(other)
          other.kind_of?(self.class) && @address == other.address
        end

        alias === eql?

        #
        # The "hash" value for the email address.
        #
        # @return [Integer]
        #   The hash of the {#address}.
        #
        def hash
          [self.class, @address].hash
        end

        #
        # Converts the email address object to a String.
        #
        # @return [String]
        #   The email address.
        #
        def to_s
          @address.to_s
        end

        alias to_str to_s

        #
        # Coerces the email address value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :email_address, address: @address}
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:email_address]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :email_address
        end

      end
    end
  end
end
