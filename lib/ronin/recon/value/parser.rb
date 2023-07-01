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

require 'ronin/recon/values/host'
require 'ronin/recon/values/domain'
require 'ronin/recon/values/wildcard'
require 'ronin/recon/values/ip'
require 'ronin/recon/values/ip_range'
require 'ronin/recon/values/website'
require 'ronin/recon/exceptions'

require 'ronin/support/text/patterns/network'
require 'ronin/support/network/public_suffix'

require 'ipaddr'
require 'uri'

module Ronin
  module Recon
    #
    # Base class for all {Values} classes.
    #
    class Value

      #
      # Module that parses strings into {Values::IP}, {Values::IPRange},
      # {Values::Domain}, {Values::Host}, or {Values::Website}.
      #
      module Parser
        # Regular expression to match IPv4 and IPv6 addresses.
        IP_REGEX = /\A#{Support::Text::Patterns::IP}\z/

        # Regular expression to match IPv4 and IPv6 CIDR ranges.
        IP_RANGE_REGEX = %r{\A(?:#{Support::Text::Patterns::IPV4_ADDR}/\d{1,2}|#{Support::Text::Patterns::IPV6_ADDR}/\d{1,3})\z}

        # Regular expression to match sub-domain host-names.
        HOSTNAME_REGEX = /\A(?:[a-zA-Z0-9_-]{1,63}\.)+#{Support::Text::Patterns::DOMAIN}\z/

        # Regular expression to match domain host-names.
        DOMAIN_REGEX = /\A#{Support::Text::Patterns::DOMAIN}\z/

        # Regular expression to match wildcard host-names.
        WILDCARD_REGEX = /\A\*(?:\.[a-z0-9_-]+)+\z/

        # Regular expression to match https:// and http:// website base URLs.
        WEBSITE_REGEX = %r{\Ahttp(?:s)?://[a-zA-Z0-9_-]+(?:\.[a-zA-Z0-9_-]+)*(?::\d+)?/?\z}

        #
        # Parses a value string.
        #
        # @param [String] string
        #   The string to parse.
        #
        # @return [Values::IP, Values::IPRange, Values::Host, Values::Domain, Values::Wildcard, Values::Website]
        #   The parsed value.
        #
        # @raise [UnknownValue]
        #   Could not identify what value the string represents.
        #
        def self.parse(string)
          case string
          when IP_RANGE_REGEX then Values::IPRange.new(string)
          when IP_REGEX       then Values::IP.new(string)
          when WEBSITE_REGEX  then Values::Website.parse(string)
          when WILDCARD_REGEX then Values::Wildcard.new(string)
          when HOSTNAME_REGEX then Values::Host.new(string)
          when DOMAIN_REGEX   then Values::Domain.new(string)
          else
            raise(UnknownValue,"unrecognized recon value: #{string.inspect}")
          end
        end
      end

      #
      # Parses a value string.
      #
      # @param [String] string
      #   The string to parse.
      #
      # @return [Values::IP, Values::IPRange, Values::Host, Values::Domain, Values::Wildcard, Values::Website]
      #   The parsed value.
      #
      # @raise [UnknownValue]
      #   Could not identify what value the string represents.
      #
      # @see Parser.parse
      #
      def self.parse(string)
        Parser.parse(string)
      end

    end
  end
end
