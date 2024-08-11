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

require 'ronin/support/text/patterns/network'
require 'async/http/internet/instance'
require 'set'

module Ronin
  module Recon
    module API
      #
      # A recon worker that queries https://crt.sh and returns host from each
      # domains certificate
      #
      class CrtSh < Worker

        register 'api/crt_sh'

        summary 'Queries https://crt.sh'

        description <<~DESC
          Queries https://crt.sh and returns the host names from each valid
          certificate for the domain.
        DESC

        accepts Domain
        outputs Host
        intensity :passive
        concurrency 1

        # The HTTP client for `https://crt.sh`.
        #
        # @return [Async::HTTP::Client]
        #
        # @api private
        attr_reader :client

        #
        # Initializes the `api/crt_sh` worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        # @api private
        #
        def initialize(**kwargs)
          super(**kwargs)

          @client = Async::HTTP::Client.new(
            Async::HTTP::Endpoint.for('https','crt.sh')
          )
        end

        # Regular expression to verify valid host names.
        #
        # @api private
        HOST_NAME_REGEX = /\A#{Support::Text::Patterns::HOST_NAME}\z/

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
          path      = "/?dNSName=#{domain}&exclude=expired&output=json"
          response  = @client.get(path)
          body      = begin
                        response.read
                      ensure
                        response.close
                      end

          certs     = JSON.parse(body, symbolize_names: true)
          hostnames = Set.new

          certs.each do |cert|
            common_name = cert[:common_name]

            if common_name &&
               common_name =~ HOST_NAME_REGEX &&
               hostnames.add?(common_name)
              yield Host.new(common_name)
            end
          end
        end

      end
    end
  end
end
