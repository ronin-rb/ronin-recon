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
require 'ronin/support/network/public_suffix'

require 'async/queue'

module Ronin
  module Recon
    module DNS
      #
      # Finds other domains with different suffixes for a given domain
      # using the [public suffix list].
      #
      # [public suffix list]: https://publicsuffix.org/
      #
      class SuffixEnum < DNSWorker

        register 'dns/suffix_enum'

        summary 'Enumerates suffixes of a domain'
        description <<~DESC
          Attempts to find other domains with different suffixes for the given
          domain using the public suffix list.
        DESC

        references [
          'https://publicsuffix.org/'
        ]

        accepts Domain

        param :concurrency, Integer, default: 10,
                                     desc:    'Sets the number of async tasks'

        # Known bad suffixes that act like wildcard domains.
        BAD_SUFFIXES = Set[
          'aquila.it',
          'arab',
          'belau.pw',
          'biz.ni',
          'com.ph',
          'com.ws',
          'co.pw',
          'df.gov.br',
          'ed.pw',
          'edu.ee',
          'edu.ps',
          'edu.ws',
          'gob.ni',
          'go.pw',
          'int.la',
          'int.ni',
          'lib.ee',
          'mil.ph',
          'mobi.tt',
          'music',
          'net.ph',
          'net.ws',
          'ngo.ph',
          'nom.za',
          'org.ee',
          'org.ph',
          'org.ws',
          'or.pw',
          'plo.ps',
          'ph',
          'vg',
          'ws',
          'გე',
          'عرب',
          '中国',
          '中國',
          '公司.cn',
          '政府',
          '網絡.cn',
          '网络.cn'
        ]

        # The public suffix list.
        #
        # @return [Ronin::Support::Network::PublicSuffixList]
        attr_reader :public_suffix_list

        #
        # Initializes the DNS suffix enum worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        def initialize(**kwargs)
          super(**kwargs)

          @public_suffix_list = Support::Network::PublicSuffix.list
        end

        #
        # Bruteforce resolves the other domains with different suffixes for the
        # given domain.
        #
        # @param [Values::Domain] domain
        #   The domain name to bruteforce.
        #
        # @yield [new_domain]
        #   Each new domain with a different public suffix.
        #
        # @yieldparam [Values::Domain] new_domain
        #   A valid domain with a different suffix.
        #
        def process(domain)
          queue = Async::LimitedQueue.new(params[:concurrency])

          domain_name, orig_suffix = @public_suffix_list.split(domain.name)

          Async do |task|
            task.async do
              public_suffixes = @public_suffix_list.non_wildcards.icann.reject do |suffix|
                BAD_SUFFIXES.include?(suffix.name)
              end

              public_suffixes.each do |suffix|
                unless suffix.name == orig_suffix
                  queue << "#{domain_name}.#{suffix.name}"
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
                while (new_domain = queue.dequeue)
                  if dns_get_address(new_domain)
                    yield Domain.new(new_domain)
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
