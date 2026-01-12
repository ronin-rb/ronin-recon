# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2026 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'ronin/support/network/ip_range'

module Ronin
  module Recon
    module Net
      #
      # A recon worker that enumerates every IP address within an IP range.
      #
      class IPRangeEnum < Worker

        register 'net/ip_range_enum'

        summary 'Enumerates the IP addresses in an IP range'

        description <<~DESC
          Enumerates over every IP address in a CIDR IP range.
        DESC

        accepts IPRange
        outputs IP
        intensity :passive

        #
        # Enumerates an IP range.
        #
        # @param [Values::IPRange] ip_range
        #   The IP range value.
        #
        # @yield [ip]
        #   Each IP value within the IP range will be yielded.
        #
        # @yieldparam [Values::IP] ip
        #   An IP value.
        #
        def process(ip_range)
          ip_range.range.each do |address|
            yield IP.new(address)
          end
        end

      end
    end
  end
end
