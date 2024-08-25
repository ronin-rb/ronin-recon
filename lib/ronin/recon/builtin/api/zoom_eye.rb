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

require_relative '../../worker'

require 'async/http/internet'

module Ronin
  module Recon
    module API
      #
      # A recon worker that queries https://api.zoomeye.hk/domain/search
      # and returns subdomain and ip addresses for a given domain
      #
      # ## Environment Variables
      #
      # * `ZOOM_EYE_API_KEY` - Specifies the API key used for authorization.
      #
      class ZoomEye < Worker

        register 'api/zoom_eye'

        summary "Queries the Domains https://api.zoomeye.hk API"
        description <<~DESC
          Queries the Domains https://api.zoomeye.hk API and returns subdomains
          and ip addresses of the domain.

          The ZoomEye API key can be specified via the api/zoom_eye.api_key
          param or the ZOOM_EYE_API_KEY env variables.
        DESC

        accepts Domain
        outputs Domain, IP
        intensity :passive
        concurrency 1

        param :api_key, String, required: true,
                                default:  ENV['ZOOM_EYE_API_KEY'],
                                desc:     'The API key for ZoomEye'

        # The HTTP client for `https://api.zoomeye.hk`.
        #
        # @return [Async::HTTP::Client]
        #
        # @api private
        #
        attr_reader :client

        #
        # Initialize the `api/zoom_eye` worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        # @api private
        #
        def initialize(**kwargs)
          super(**kwargs)

          @client = Async::HTTP::Client.new(
            Async::HTTP::Endpoint.for('https', 'api.zoomeye.hk')
          )
        end

        #
        # Returns associated domain names and ip addresses
        #
        # @param [Values::Domain] domain
        #   The domain value to gather subdomains and ip_addresses for.
        #
        # @yield [value]
        #   For each subdomain found through the API, a Domain
        #   and optionaly IP will be yielded.
        #
        # @yieldparam [Values::Domain, Values::IP] value
        #   The domain or ip found.
        #
        def process(domain)
          path     = "/domain/search?q=#{domain}&type=1"
          response = @client.get(path, { 'API-KEY' => params[:api_key] })
          body     = begin
                       JSON.parse(response.read, symbolize_names: true)
                     ensure
                       response.close
                     end

          list = body.fetch(:list, [])

          list.each do |record|
            if (subdomain = record[:name])
              yield Domain.new(subdomain)
            end

            ip_addresses = record.fetch(:ip, [])

            ip_addresses.each do |ip_addr|
              yield IP.new(ip_addr)
            end
          end
        end

      end
    end
  end
end
