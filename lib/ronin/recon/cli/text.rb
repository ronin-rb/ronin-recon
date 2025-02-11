# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2025 Hal Brodigan (postmodern.mod3@gmail.com)
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

require_relative '../values'

module Ronin
  module Recon
    class CLI
      #
      # Helper methods for generating display text.
      #
      # @since 0.2.0
      #
      module Text
        # Mapping of {Value} classes to printable names.
        VALUE_CLASS_NAMES = {
          Values::Domain       => 'domain',
          Values::Mailserver   => 'mailserver',
          Values::Nameserver   => 'nameserver',
          Values::Wildcard     => 'wildcard host name',
          Values::Host         => 'host',
          Values::IP           => 'IP address',
          Values::IPRange      => 'IP range',
          Values::OpenPort     => 'open port',
          Values::Cert         => 'SSL/TLS certificate',
          Values::Website      => 'website',
          Values::URL          => 'URL',
          Values::EmailAddress => 'email addresse'
        }

        #
        # Converts the value class into a printable name.
        #
        # @param [Class<Value>] value_class
        #   The value class.
        #
        # @return [String]
        #   The descriptive name for the value class.
        #
        # @raise [NotImplementedError]
        #
        def value_class_name(value_class)
          VALUE_CLASS_NAMES.fetch(value_class) do
            raise(NotImplementedError,"unknown value class: #{value_class.inspect}")
          end
        end

        #
        # Formats a value object into a human readable string.
        #
        # @param [Value] value
        #   The value object to format.
        #
        # @return [String]
        #   The formatted value.
        #
        # @raise [NotImplementedError]
        #   The given value object was not supported.
        #
        def format_value(value)
          case value
          when Values::Domain       then "domain #{value}"
          when Values::Mailserver   then "mailserver #{value}"
          when Values::Nameserver   then "nameserver #{value}"
          when Values::Wildcard     then "wildcard host name #{value}"
          when Values::Host         then "host #{value}"
          when Values::IP           then "IP address #{value}"
          when Values::IPRange      then "IP range #{value}"
          when Values::OpenPort     then "open #{value.protocol.upcase} port #{value}"
          when Values::Cert         then "SSL/TLS certificate #{value.subject}"
          when Values::Website      then "website #{value}"
          when Values::URL          then "URL #{value}"
          when Values::EmailAddress then "email address #{value}"
          else
            raise(NotImplementedError,"value class #{value.class} not supported")
          end
        end
      end
    end
  end
end
