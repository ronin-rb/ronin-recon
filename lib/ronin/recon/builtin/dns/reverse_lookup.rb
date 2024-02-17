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

require 'ronin/recon/dns_worker'

module Ronin
  module Recon
    module DNS
      #
      # Performs reverse DNS lookup on an IP address and finds it's host name.
      #
      class ReverseLookup < DNSWorker

        register 'dns/reverse_lookup'

        summary 'Reverse looks up an IP address'
        description <<~DESC
          Reverse looks up an IP address and return the host names associated
          with the IP address.
        DESC

        accepts IP
        outputs Host

        #
        # Reverse DNS looks up an IP address and finds it's host name.
        #
        # @param [Values::IP] ip
        #
        # @yield [host]
        #
        # @yieldparam [Values::Host] host
        #
        def process(ip)
          unless ip.host
            # NOTE: only query IP addresses not associated with a hostname
            dns_get_ptr_names(ip.address).each do |host_name|
              yield Host.new(host_name.chomp('.'))
            end
          end
        end

      end
    end
  end
end
