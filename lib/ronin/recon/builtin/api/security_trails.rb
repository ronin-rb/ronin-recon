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

require 'ronin/recon/worker'
require 'ronin/support/text/patterns/network'

require 'async/http/internet/instance'
require 'set'

module Ronin
  module Recon
    module API
      #
      # A recon worker that queries https://securitytrails.com and returns subdomains
      # for a given domain.
      #
      class SecurityTrails < Worker

        register 'api/security_trails'

        author "Nicolò Rebughini", email: "nicolo.rebughini@gmail.com"
        summary "Queries the Domains https://securitytrails.com API"
        description <<~DESC
          Queries the Domains https://securitytrails.com API and returns the subdomains
          of the domain.
        DESC

        accepts Domain
        outputs Host
        intensity :passive
        concurrency 1

        param :api_key, String, required: true,
                                default:  ENV['SECURITYTRAILS_API_KEY'],
                                desc:     'The API key for SecurityTrails'

        #
        # The HTTP client for `https://securitytrails.com`.
        #
        # @return [Async::HTTP::Client]
        #
        # @api private
        #
        attr_reader :client

        #
        # Initializes the `api/security_trails` worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        # @api private
        #
        def initialize(**kwargs)
          super(**kwargs)

          @client = Async::HTTP::Client.new(
            Async::HTTP::Endpoint.for('https','api.securitytrails.com')
          )
        end

        #
        # Returns host from each domains certificate.
        #
        # @param [Values::Domain] domain
        #   The domain value to gather subdomains for.
        #
        # @yield [host]
        #   For each subdmomain found through the API, a Domain
        #   value will be yielded.
        #
        # @yieldparam [Values::Host] subdomain
        #   The host found.
        #
        def process(domain)
          path         = "/v1/domain/#{domain}/subdomains?children_only=false&include_inactive=false"
          response     = @client.get(path, { 'APIKEY' => params[:api_key] })
          body         = begin
                           JSON.parse(response.read, symbolize_names: true)
                         ensure
                           response.close
                         end
          subdomains   = body.fetch(:subdomains, [])
          full_domains = Set.new

          subdomains.each do |subdomain|
            full_domain = "#{subdomain}.#{domain}"

            yield Host.new(full_domain) if full_domains.add?(full_domain)
          end
        end

      end
    end
  end
end
