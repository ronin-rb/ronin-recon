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

require 'async/io'

module Ronin
  module Recon
    module Net
      #
      # A recon worker that grabs the SSL/TLS certificate from open ports that
      # use SSL/TLS.
      #
      class CertGrab < Worker

        register 'net/cert_grab'

        accepts OpenPort
        outputs Cert

        summary 'Fetches the SSL/TLS certificate from an open port'

        description <<~DESC
          Grabs and decodes the X509 SSL/TLS peer certificate from an open port
          which supports SSL/TLS.
        DESC

        #
        # Grabs the TLS certificate from the open port, if it supports SSL/TLS.
        #
        # @param [Values::OpenPort] open_port
        #   The open port value to check.
        #
        # @yield [cert]
        #   If the open port supports SSL/TLS, then a certificate value will be
        #   yielded.
        #
        # @yieldparam [Values::Cert] cert
        #   The grabbed certificate value.
        #
        def process(open_port)
          if open_port.ssl?
            address  = open_port.address
            port     = open_port.number
            endpoint = Async::IO::Endpoint.ssl(address,port)

            endpoint.connect do |socket|
              peer_cert = socket.peer_cert

              yield Cert.new(peer_cert)
            end
          end
        end

      end
    end
  end
end
