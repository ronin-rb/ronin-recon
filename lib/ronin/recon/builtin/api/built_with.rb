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

require 'async/http/internet/instance'
require 'set'

module Ronin
  module Recon
    module API
      #
      # A recon worker that queries https://api.builtwith.com and return
      # informations for given domain
      #
      # ## Environment Variables
      #
      # * `BUILT_WITH_API_KEY` - Specifies the API key used for authorization.
      #
      class BuiltWith < Worker

        register 'api/built_with'

        summary "Queries the domain informations from https://api.builtwith.com"
        description <<~DESC
          Queriest the domain informations from https://api.builtwith.com.
          
          The BuiltWith API key can be specified via the api/built_with.api_key
          param or the BUILT_WITH_API_KEY environment variables.
        DESC

        accepts Domain
        outputs Domain, EmailAddress
        intensity :passive
        concurrency 1

        param :api_key, String, required: true,
                                default:  ENV['BUILT_WITH_API_KEY'],
                                desc:     'The API key for BuiltWith'

        #
        # The HTTP client for `https://api.builtwith.com`
        #
        # @return [Async::HTTP::Client]
        #
        # @api private
        #
        attr_reader :client

        #
        # Initializes the `api/built_with` worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        # @api private
        #
        def initialize(**kwargs)
          super(**kwargs)

          @client = Async::HTTP::Client.new(
            Async::HTTP::Endpoint.for('https', 'api.builtwith.com')
          )
        end

        #
        # Returns all informations queried for given domain
        #
        # @param [Values::Domain] domain
        #   The domain value to gather informations for.
        #
        # @yield [Value] value
        #   The found value will be yielded
        #
        # @yieldparam [Values::Domain, Values::EmailAddress]
        #   The found domains or email addresses
        #
        def process(domain)
          path     = "/v21/api.json?KEY=#{params[:api_key]}&LOOKUP=#{domain}"
          response = client.get(path)
          body     = begin
                       JSON.parse(response.read, symbolize_names: true)
                      ensure
                        response.close
                     end

          domains         = Set.new
          email_addresses = Set.new

          body.fetch(:Results, []).each do |results|
            paths = results.fetch(:Result, {}).fetch(:Paths, [])

            paths.each do |result_path|
              if (sub_domain = result_path[:SubDomain])
                new_domain = "#{sub_domain}.#{domain}"

                yield Domain.new(new_domain) if domains.add?(new_domain)
              end
            end

            emails = results.fetch(:Meta, {}).fetch(:Emails, [])
            
            emails.each do |email|
              yield EmailAddress.new(email) if email_addresses.add?(email)
            end
          end
        end
      end
    end
  end
end
