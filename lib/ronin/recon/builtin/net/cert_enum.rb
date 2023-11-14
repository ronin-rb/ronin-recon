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

require 'ronin/recon/worker'
require 'ronin/recon/value/parser'

require 'async/io'

module Ronin
  module Recon
    module Net
      #
      # A recon worker that enumerates over the host names within the SSL/TLS
      # certificate.
      #
      class CertEnum < Worker

        register 'net/cert_enum'

        summary 'Enumerates over the host names within a SSL/TLS certificate'

        description <<~DESC
          Enumerates over the subject CommonName and subjectAltNames of a
          SSL/TLS certificate.
        DESC

        accepts Cert
        outputs Domain, Host, Wildcard, EmailAddress

        #
        # Grabs the TLS certificate from the open port, if it supports SSL/TLS.
        #
        # @param [Values::Cert] cert
        #   The SSL/TLS certificate.
        #
        # @yield [name]
        #   All host names, wildcard host names, IP addresses, or email
        #   addresses, from the SSL/TLS certificate will be yielded.
        #
        # @yieldparam [Values::Host, Values::Wildcard, Values::IP, Values::EmailAddress] name
        #   A host name, wildcard host name, IP address, or email address from
        #   the certificate.
        #
        def process(cert)
          subject_entries = cert.subject.to_a
          subject_entries.each do |entry|
            case entry[0]
            when 'CN' # Common Name
              case entry[1]
              when Value::Parser::DOMAIN_REGEX
                yield Domain.new(entry[1])
              when Value::Parser::HOSTNAME_REGEX
                yield Host.new(entry[1])
              end
            when 'emailAddress'
              yield EmailAddress.new(entry[1])
            end
          end

          subject_alt_names = cert.extensions.find do |ext|
            ext.oid == 'subjectAltName'
          end

          if subject_alt_names
            values = subject_alt_names.value.split(', ')

            values.each do |string|
              name, value = string.split(':',2)

              case name
              when 'DNS'
                case value
                when Value::Parser::DOMAIN_REGEX
                  yield Domain.new(value)
                when Value::Parser::HOSTNAME_REGEX
                  yield Host.new(value)
                when Value::Parser::WILDCARD_REGEX
                  yield Wildcard.new(value)
                end
              when 'IP'
                yield IP.new(value)
              when 'email'
                yield EmailAddress.new(value)
              end
            end
          end
        end

      end
    end
  end
end
