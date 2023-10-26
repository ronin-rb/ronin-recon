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

require 'async/http/internet/instance'

module Ronin
  module Recon
    module Net
      #
      # A recon worker that returns host from each domains certificate
      #
      class CertSh < Worker

        register 'net/cert_sh'

        accepts Domain

        summary 'Queries cert.sh and returns host from each domains certificate.'

        description <<~DESC
          Queries cert.sh and returns host from each domains certificate.
        DESC

        #
        # Returns host from each domains certificate.
        #
        # @param [Values::Domain] domain
        #   The domain value to check.
        #
        # @yield [host]
        #   If the domain has certificates, then a host value will be
        #   yielded.
        #
        # @yieldparam [Values::Host] host
        #   The host from certificate.
        #
        def process(domain)
          Async do
            internet = Async::HTTP::Internet.instance
            path     = "https://crt.sh/?dNSName=#{domain}&exclude=expired&output=json"

            response = internet.get(path)
            certs    = JSON.parse(response.read, symbolize_names: true)

            certs.each do |cert|
              if cert[:common_name]
                yield Host.new(cert[:common_name])
              end
            end
          end
        end
      end
    end
  end
end