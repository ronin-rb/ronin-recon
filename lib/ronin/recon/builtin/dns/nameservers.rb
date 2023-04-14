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
      # Finds the nameservers associated with a domaim.
      #
      class Nameservers < DNSWorker

        register 'dns/nameservers'

        summary 'Looks up the nameservers of a domain'
        description <<~DESC
          Queries the nameservers (NS records) for a domain name.
        DESC

        accepts Domain

        #
        # Looks up the nameservers of a given domain.
        #
        # @param [Values::Domain] domain
        #   The domain value.
        #
        # @yield [nameserver]
        #   The discovered nameservers will be yielded.
        #
        # @yieldparam [Values::Nameserver] nameserver
        #
        def process(domain)
          dns_get_nameservers(domain.name).each do |nameserver|
            yield Nameserver.new(nameserver.chomp('.'))
          end
        end

      end
    end
  end
end
