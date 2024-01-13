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
      # Finds other host names by querying common `SRV` record names under a
      # domain.
      #
      class SRVEnum < DNSWorker

        # Common `SRV` record names.
        RECORD_NAMES = %w[
          _gc._tcp
          _kerberos._tcp
          _kerberos._udp
          _ldap._tcp
          _test._tcp
          _sips._tcp
          _sip._udp
          _sip._tcp
          _aix._tcp
          _aix._tcp
          _finger._tcp
          _ftp._tcp
          _http._tcp
          _nntp._tcp
          _telnet._tcp
          _whois._tcp
          _h323cs._tcp
          _h323cs._udp
          _h323be._tcp
          _h323be._udp
          _h323ls._tcp
          _https._tcp
          _h323ls._udp
          _sipinternal._tcp
          _sipinternaltls._tcp
          _sip._tls
          _sipfederationtls._tcp
          _jabber._tcp
          _xmpp-server._tcp
          _xmpp-client._tcp
          _xmpp-server._udp
          _xmpp-client._udp
          _imap.tcp
          _certificates._tcp
          _crls._tcp
          _pgpkeys._tcp
          _pgprevokations._tcp
          _cmp._tcp
          _svcp._tcp
          _crl._tcp
          _ocsp._tcp
          _PKIXREP._tcp
          _smtp._tcp
          _hkp._tcp
          _hkps._tcp
          _jabber._udp
          _jabber-client._tcp
          _jabber-client._udp
          _kerberos.tcp.dc._msdcs
          _ldap._tcp.ForestDNSZones
          _ldap._tcp.dc._msdcs
          _ldap._tcp.pdc._msdcs
          _ldap._tcp.gc._msdcs
          _kerberos._tcp.dc._msdcs
          _kpasswd._tcp
          _kpasswd._udp
          _imap._tcp
          _imaps._tcp
          _submission._tcp
          _pop3._tcp
          _pop3s._tcp
          _caldav._tcp
          _caldavs._tcp
          _carddav._tcp
          _carddavs._tcp
          _x-puppet._tcp
          _x-puppet-ca._tcp
          _autodiscover._tcp
        ]

        register 'dns/srv_enum'

        summary 'Enumerates common SRV record names for a domain'
        description <<~DESC
          Attempts to find additional hosts by querying common SRV record names
          for the domain name.
        DESC

        accepts Domain
        outputs Host

        param :concurrency, Integer, default: 10,
                                     desc:    'Sets the number of async tasks'

        #
        # Bruteforce resolves common `SRV` records for a domain.
        #
        # @param [Values::Domain] domain
        #   The domain to query.
        #
        # @yield [host]
        #   A discovered host from `SRV` record under the domain.
        #
        # @yieldparam [Values::Host] host
        #   A host name pointed to by a `SRV` record under the domain.
        #
        def process(domain)
          wordlist = RECORD_NAMES
          queue    = Async::LimitedQueue.new(params[:concurrency])

          Async do |task|
            task.async do
              # populate the queue with SRV record names to query
              wordlist.each do |name|
                queue << "#{name}.#{domain.name}"
              end

              # send stop messages for each sub-task
              params[:concurrency].times do
                queue << nil
              end
            end

            # spawn the sub-tasks
            params[:concurrency].times do
              task.async do
                while (name = queue.dequeue)
                  records = dns_get_srv_records(name)

                  records.each do |record|
                    # BUG: async-dns will return `CNAME` records for domains
                    # with catch-all subdomain aliases.
                    if record.kind_of?(Resolv::DNS::Resource::IN::SRV)
                      hostname = record.target.to_s
                      hostname.chomp!('.')

                      unless hostname.empty?
                        yield Host.new(hostname)
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
  end
end
