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
    module Workers
      module DNS
        #
        # Finds the mailservers for the domain.
        #
        class Mailservers < DNSWorker

          register 'dns/mailservers'

          accepts Domain

          #
          # Finds the mailservers for the given domain.
          #
          # @param [Values::Domain] domain
          #   The given domain value.
          #
          # @yield [mailserver]
          #   Each discovered mailserver will be yielded.
          #
          # @yieldparam [Values::Mailserver] mailserver
          #   A discovered mailserver.
          #
          def process(domain)
            dns_get_mailservers(domain.name).each do |mailserver|
              unless mailserver == '.'
                yield Mailserver.new(mailserver.chomp('.'))
              end
            end
          end

        end
      end
    end
  end
end
