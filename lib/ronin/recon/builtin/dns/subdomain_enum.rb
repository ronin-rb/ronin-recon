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
require 'ronin/recon/root'

require 'wordlist'
require 'async/queue'

module Ronin
  module Recon
    module DNS
      #
      # Finds common subdomains of a domain using a wordlist of commong
      # subdomains.
      #
      class SubdomainEnum < DNSWorker

        DEFAULT_WORDLIST = File.join(WORDLISTS_DIR, 'subdomains-1000.txt.gz')

        register 'dns/subdomain_enum'

        summary 'Enumerates subdomains of a domain'
        description <<~DESC
          Attempts to find the subdomains of a given domain by looking up
          host names of the domain using a wordlist of common subdomains.
        DESC

        accepts Domain, Wildcard
        outputs Host

        param :concurrency, Integer, default: 10,
                                     desc:    'Sets the number of async tasks'

        param :wordlist, String, desc: 'Optional subdomain wordlist to use'

        #
        # Bruteforce resolves the subdomains of a given domain.
        #
        # @param [Values::Domain, Values::Wildcard] domain
        #   The domain or wildcard host name to bruteforce.
        #
        # @yield [host]
        #   Subdomains that have DNS records will be yielded.
        #
        # @yieldparam [Values::Host] host
        #   A valid subdomain of the domain.
        #
        def process(domain)
          wordlist = Wordlist.open(params[:wordlist] || DEFAULT_WORDLIST)
          queue    = Async::LimitedQueue.new(params[:concurrency])

          Async do |task|
            task.async do
              case domain
              when Domain
                wordlist.each do |name|
                  queue << "#{name}.#{domain.name}"
                end
              when Wildcard
                wordlist.each do |name|
                  queue << domain.template.sub('*',name)
                end
              end

              # send stop messages for each sub-task
              params[:concurrency].times do
                queue << nil
              end
            end

            # spawn the sub-tasks
            params[:concurrency].times do
              task.async do
                while (subdomain = queue.dequeue)
                  if dns_get_address(subdomain)
                    yield Host.new(subdomain)
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
