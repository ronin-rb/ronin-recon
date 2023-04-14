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

require 'ronin/recon/dns_worker'

module Ronin
  module Recon
    module DNS
      #
      # Looks up the IP address of a host name, domain, nameserver, or
      # mailserver.
      #
      class Lookup < DNSWorker

        register 'dns/lookup'

        summary 'Looks up the IPs of a host-name'
        description <<~DESC
          Resolves the IP addresses of domains, host names, nameservers,
          and mailservers.
        DESC

        accepts Domain, Host, Nameserver, Mailserver

        #
        # Resolves the IP address for the given host.
        #
        # @param [Values::Host, Values::Domain, Values::Nameserver, Values::Mailserver] host
        #   The host name to resolve.
        #
        # @yield [ip]
        #
        # @yieldparam [Values::IP] ip
        #   An IP address for the host.
        #
        def process(host)
          addresses = dns_get_addresses(host.name)

          addresses.each do |address|
            yield IP.new(address)
          end
        end

      end
    end
  end
end
