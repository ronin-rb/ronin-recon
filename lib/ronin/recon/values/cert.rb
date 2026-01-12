# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2026 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'ronin/support/crypto'

module Ronin
  module Recon
    module Values
      #
      # Represents a SSL/TLS certificate.
      #
      class Cert < Value

        # The certificate object.
        #
        # @return [Ronin::Support::Crypto::Cert]
        #
        # @api private
        attr_reader :cert

        #
        # Initializes the certificate value.
        #
        # @param [Ronin::Support::Crypto::Cert, OpenSSL::X509::Certificate] cert
        #   The decoded X509 certificate.
        #
        def initialize(cert)
          @cert = Support::Crypto::Cert(cert)
        end

        #
        # The serial number of the SSL/TLS certificate.
        #
        # @return [OpenSSL::BN]
        #
        def serial
          @cert.serial
        end

        #
        # When the certificate begins being valid.
        #
        # @return [Time]
        #
        def not_before
          @cert.not_before
        end

        #
        # When the certificate expires.
        #
        # @return [Time]
        #
        def not_after
          @cert.not_after
        end

        #
        # The certificate issuer's information.
        #
        # @return [Ronin::Support::Crypto::Cert::Name]
        #
        def issuer
          @cert.issuer
        end

        #
        # The certificate subject's information.
        #
        # @return [Ronin::Support::Crypto::Cert::Name]
        #
        def subject
          @cert.subject
        end

        #
        # Additional certificate extensions.
        #
        # @return [Array<OpenSSL::X509::Extensions>]
        #
        def extensions
          @cert.extensions
        end

        #
        # Compares the certificate to another value.
        #
        # @param [Object] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          self.class == other.class && serial == other.serial
        end

        #
        # The "hash" value of the certificate.
        #
        # @return [Integer]
        #   The hash value derived from the class and the parsed certificates
        #   serial number.
        #
        def hash
          [self.class, @cert.serial].hash
        end

        #
        # Converts the certificate to a string.
        #
        # @return [String]
        #
        def to_s
          @cert.to_s
        end

        #
        # Converts the certificate to a hash of attributes
        #
        # @return [Hash{Symbol => Object}]
        #
        def as_json
          {
            serial:            @cert.serial,
            not_before:        @cert.not_before,
            not_after:         @cert.not_after,
            subject:           @cert.subject.to_h,
            issuer:            @cert.issuer.to_h,
            extensions:        @cert.extensions_hash,
            subject_alt_names: @cert.subject_alt_names,
            pem:               @cert.to_pem
          }
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:cert]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :cert
        end

      end
    end
  end
end
