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

require 'ronin/recon/values/wildcard'
require 'ronin/recon/values/domain'
require 'ronin/recon/values/host'
require 'ronin/recon/values/ip_range'
require 'ronin/recon/values/ip'

module Ronin
  module Recon
    #
    # Defines which domains, hosts, IP addresses are considered "in scope".
    #
    # @api private
    #
    class Scope

      # List of domain or IP range values which are considered "in scope".
      #
      # @return [Array<Values::Domain, Values::Host, Values::IPRange, Values::IP>]
      attr_reader :values

      # The list of values to ignore and are not considered "in scope".
      #
      # @return [Array<Value>]
      attr_reader :ignore

      #
      # Initializes the scope.
      #
      # @param [Array<Values::Wildcard, Values::Domain, Values::Host, Values::IPRange, Values::IP>] values
      #   The list of "in scope" values.
      #
      # @param [Array<Value>] ignore
      #   The recon values to ignore and are not "in scope".
      #
      # @raise [NotImplementedError]
      #   An unsupported value object was given.
      #
      def initialize(values, ignore: [])
        @values = values
        @ignore = ignore

        @host_values = []
        @ip_values   = []

        values.each do |value|
          case value
          when Values::Wildcard, Values::Domain, Values::Host
            @host_values << value
          when Values::IP, Values::IPRange
            @ip_values << value
          else
            raise(NotImplementedError,"scope value type not supported: #{value.inspect}")
          end
        end
      end

      #
      # Determines if a value is "in scope".
      #
      # @param [Value] value
      #   The value to check.
      #
      # @return [Boolean]
      #   Indicates whether the value is "in scope" or not.
      #   If the given value is not a {Values::Domain Domain},
      #   {Values::Host Host}, {Values::IPRange IPRange}, or {Values::IP IP}
      #   then `true` is returned by default.
      #
      def include?(value)
        scope_values = case value
                       when Values::Wildcard, Values::Domain, Values::Host
                         @host_values
                       when Values::IP, Values::IPRange
                         @ip_values
                       end

        return false if @ignore.any? { |ignore| ignore === value }

        if (scope_values && !scope_values.empty?)
          scope_values.any? { |scope_value| scope_value === value }
        else
          true
        end
      end

    end
  end
end
