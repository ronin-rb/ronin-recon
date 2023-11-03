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

module Ronin
  module Recon
    module Net
      #
      # A recon worker that identifies services on open ports.
      #
      class ServiceFingerprint < Worker

        register 'net/service_id'

        accepts OpenPort

        summary 'Identifies services running on open ports'

        description <<~DESC
          Identifies various services that are running on open ports.
        DESC

        #
        # Identifies the service running on an open port.
        #
        # @param [Values::OpenPort] open_port
        #   The given open port.
        #
        # @yield [new_value]
        #   The identified service will be yielded.
        #
        # @yieldparam [Values::Nameserver, Values::Mailserver, Values::Website] new_value
        #   A discovered nameserver, mailserver, or website.
        #
        def process(open_port)
          case open_port.service
          when 'domain'
            yield Nameserver.new(open_port.host)
          when 'smtp'
            yield Mailserver.new(open_port.host)
          when 'http'
            if open_port.ssl?
              yield Website.https(open_port.host,open_port.number)
            else
              yield Website.http(open_port.host,open_port.number)
            end
          when 'https'
            yield Website.https(open_port.host,open_port.number)
          end
        end

      end
    end
  end
end
