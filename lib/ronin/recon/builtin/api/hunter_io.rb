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
      # A recon worker that queries https://api.hunter.io/domain-search
      # and returns corresponding email addresses.
      #
      # ## Environment Variables
      #
      # * `HUNTER_IO_API_KEY` - Specifies the API key used for authorization.
      #
      class HunterIO < Worker

        register 'api/hunter_io'

        summary "Queries the Domains https://api.hunter.io/domain-search"
        description <<~DESC
          Queries the Domains https://api.hunter.io/domain-search and returns
          corresponding email addresses.

          The hunter.io API key can be specified via the api/hunter_io.api_key
          param or the HUNTER_IO_API_KEY env variables.
        DESC

        accepts Domain
        outputs EmailAddress
        intensity :passive
        concurrency 1

        param :api_key, String, required: true,
                                default:  ENV['HUNTER_IO_API_KEY'],
                                desc:     'The API key for hunter.io'

        # The HTTP client for `https://api.hunter.io`.
        #
        # @return [Async::HTTP::Client]
        #
        # @api private
        attr_reader :client

        #
        # Initializes the `api/hunter` worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        # @api private
        #
        def initialize(**kwargs)
          super(**kwargs)

          @client = Async::HTTP::Client.new(
            Async::HTTP::Endpoint.for('https', 'api.hunter.io')
          )
        end

        #
        # Returns email addresses corresponding to domain."
        #
        # @param [Values::Domain] domain
        #   The domain value to gather email addresses for.
        #
        # @yield [email]
        #   For each email address found through the API, a EmailAddress
        #   value will be yielded.
        #
        # @yieldparam [Values::EmailAddress] email_address
        #   The emial addresses found.
        #
        def process(domain)
          path     = "/v2/domain-search?domain=#{domain}&api_key=#{params[:api_key]}"
          response = @client.get(path)
          body     = begin
                   JSON.parse(response.read, symbolize_names: true)
                 ensure
                   response.close
                 end

          if (emails = body.dig(:data, :emails))
            emails.each do |email|
              if (email_addr = email[:value])
                yield EmailAddress.new(email_addr)
              end
            end
          end
        end

      end
    end
  end
end
