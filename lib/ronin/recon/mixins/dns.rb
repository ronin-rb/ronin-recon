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

require 'ronin/support/network/dns/idn'

require 'async/io'
require 'async/dns/resolver'

module Ronin
  module Recon
    module Mixins
      #
      # Mixin which adds methods for performing async DNS queries.
      #
      # @api public
      #
      module DNS
        # Handles International Domain Names (IDN).
        IDN = Support::Network::DNS::IDN

        # @return [Async::DNS::Resolver]
        attr_reader :dns_resolver

        #
        # Initializes the DNS resolver.
        #
        # @param [Array<String>] nameservers
        #   The DNS nameservers to query.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        def initialize(nameservers: Support::Network::DNS.nameservers, **kwargs)
          super(**kwargs)

          @dns_resolver = Async::DNS::Resolver.new(
            nameservers.map { |ip| [:udp, ip, 53] }
          )
        end

        #
        # Looks up all addresses of a hostname.
        #
        # @param [String] host
        #   The hostname to lookup.
        #
        # @return [Array<String>]
        #   The addresses of the hostname.
        #
        def dns_get_addresses(host)
          host = IDN.to_ascii(host)

          begin
            @dns_resolver.addresses_for(host).map(&:to_s)
          rescue Async::DNS::ResolutionFailure
            return []
          end
        end

        #
        # Looks up the address of a hostname.
        #
        # @param [String] host
        #   The hostname to lookup.
        #
        # @return [String, nil]
        #   The address of the hostname.
        #
        def dns_get_address(host)
          dns_get_addresses(host).first
        end

        #
        # Looks up all hostnames associated with the address.
        #
        # @param [String] ip
        #   The IP address to lookup.
        #
        # @return [Array<String>]
        #   The hostnames of the address.
        #
        def dns_get_names(ip)
          # TODO
        end

        #
        # Looks up the hostname of the address.
        #
        # @param [String] ip
        #   The IP address to lookup.
        #
        # @return [String, nil]
        #   The hostname of the address.
        #
        def dns_get_name(ip)
          dns_get_names(ip).first
        end

        alias dns_reverse_lookup dns_get_name

        # Mapping of record types to `Resolv::DNS::Resource::IN` classes.
        #
        # @api private
        RECORD_TYPES = {
          a:     Resolv::DNS::Resource::IN::A,
          aaaa:  Resolv::DNS::Resource::IN::AAAA,
          any:   Resolv::DNS::Resource::IN::ANY,
          cname: Resolv::DNS::Resource::IN::CNAME,
          hinfo: Resolv::DNS::Resource::IN::HINFO,
          loc:   Resolv::DNS::Resource::IN::LOC,
          minfo: Resolv::DNS::Resource::IN::MINFO,
          mx:    Resolv::DNS::Resource::IN::MX,
          ns:    Resolv::DNS::Resource::IN::NS,
          ptr:   Resolv::DNS::Resource::IN::PTR,
          soa:   Resolv::DNS::Resource::IN::SOA,
          srv:   Resolv::DNS::Resource::IN::SRV,
          txt:   Resolv::DNS::Resource::IN::TXT,
          wks:   Resolv::DNS::Resource::IN::WKS
        }

        #
        # Queries all matching DNS records for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @param [:a, :aaaa, :any, :cname, :hinfo, :loc, :minfo, :mx, :ns, :ptr, :soa, :srv, :txt, :wks] record_type
        #   The record type.
        #
        # @return [Array<Resolv::DNS::Resource>]
        #   All matching DNS records.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource
        #
        def dns_get_records(name,record_type)
          name = IDN.to_ascii(name)

          record_class = RECORD_TYPES.fetch(record_type) do
            raise(ArgumentError,"invalid record type: #{record_type.inspect}")
          end

          if (message = @dns_resolver.query(name,record_class))
            message.answer.map { |answer| answer[2] }
          else
            []
          end
        end

        #
        # Queries a single matching DNS record for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @param [:a, :aaaa, :any, :cname, :hinfo, :loc, :minfo, :mx, :ns, :ptr, :soa, :srv, :txt, :wks] record_type
        #   The record type.
        #
        # @return [Resolv::DNS::Resource, nil]
        #   The matching DNS records or `nil` if no matching DNS records
        #   could be found.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource
        #
        def dns_get_record(name,record_type)
          dns_get_records(name,record_type).first
        end

        #
        # Queries all records of the host name using the `ANY` DNS query.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource>]
        #   All of the DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/ANY
        #
        def dns_get_any_records(name)
          dns_get_records(name,:any)
        end

        #
        # Queries the `CNAME` record for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::IN::CNAME, nil]
        #   The `CNAME` record or `nil` if the host name has no `CNAME`
        #   record.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/CNAME
        #
        def dns_get_cname_record(name)
          dns_get_record(name,:cname)
        end

        #
        # Queries the canonical name for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [String, nil]
        #   The canonical name for the host or `nil` if the host has no
        #   `CNAME` record.
        #
        def dns_get_cname(name)
          if (record = dns_get_cname_record(name))
            record.name.to_s
          end
        end

        #
        # Queries the `HINFO` record for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::IN::HINFO, nil]
        #   The `HINFO` DNS record or `nil` if the host name has no `HINFO`
        #   record.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/HINFO
        #
        def dns_get_hinfo_record(name)
          dns_get_record(name,:hinfo)
        end

        #
        # Queries the first `A` record belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::IN::A, nil]
        #   The first `A` DNS record or `nil` if the host name has no `A`
        #   records.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/IN/A
        #
        def dns_get_a_record(name)
          dns_get_record(name,:a)
        end

        #
        # Queries the first IPv4 address belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [String, nil]
        #   The first IPv4 address belonging to the host name.
        #
        def dns_get_a_address(name)
          if (record = dns_get_a_record(name))
            record.address.to_s
          end
        end

        #
        # Queries all `A` records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::IN::A>]
        #   All of the `A` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/IN/A
        #
        def dns_get_a_records(name)
          dns_get_records(name,:a)
        end

        #
        # Queries all IPv4 addresses belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<String>]
        #   All of the IPv4 addresses belonging to the host name.
        #
        def dns_get_a_addresses(name)
          dns_get_a_records(name).map do |record|
            record.address.to_s
          end
        end

        #
        # Queries the first `AAAA` DNS records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::IN::AAAA, nil]
        #   The first `AAAA` DNS record or `nil` if the host name has no
        #   `AAAA` records.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/IN/AAAA
        #
        def dns_get_aaaa_record(name)
          dns_get_record(name,:aaaa)
        end

        #
        # Queries the first IPv6 address belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [String, nil]
        #   The first IPv6 address or `nil` if the host name has no IPv6
        #   addresses.
        #
        def dns_get_aaaa_address(name)
          if (record = dns_get_aaaa_record(name))
            record.address.to_s
          end
        end

        #
        # Queries all `AAAA` DNS records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::IN::AAAA>]
        #   All of the `AAAA` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/IN/AAAA
        #
        def dns_get_aaaa_records(name)
          dns_get_records(name,:aaaa)
        end

        #
        # Queries all IPv6 addresses belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<String>]
        #   All IPv6 addresses belonging to the host name.
        #
        def dns_get_aaaa_addresses(name)
          dns_get_aaaa_records(name).map do |record|
            record.address.to_s
          end
        end

        #
        # Queries all `SRV` DNS records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::IN::SRV>]
        #   All `SRV` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/IN/SRV
        #
        def dns_get_srv_records(name)
          dns_get_records(name,:srv)
        end

        #
        # Queries all `WKS` (Well-Known-Service) DNS records belonging to the
        # host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::IN::WKS>]
        #   All `WKS` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/IN/WKS
        #
        def dns_get_wks_records(name)
          dns_get_records(name,:wks)
        end

        #
        # Queries the `LOC` (Location) DNS record of the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::LOC, nil]
        #   The `LOC` DNS record of the host name or `nil` if the host name
        #   has no `LOC` record.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/LOC
        #
        def dns_get_loc_record(name)
          dns_get_record(name,:loc)
        end

        #
        # Queries the `MINFO` (Machine-Info) DNS record of the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::MINFO, nil]
        #   The `MINFO` DNS record of the host name or `nil` if the host name
        #   has no `MINFO` record.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/MINFO
        #
        def dns_get_minfo_record(name)
          dns_get_record(name,:minfo)
        end

        #
        # Queries all `MX` DNS records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::MX>]
        #   All `MX` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/MX
        #
        def dns_get_mx_records(name)
          dns_get_records(name,:mx)
        end

        #
        # Queries the mailservers for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<String>]
        #   The host names of the mailservers serving the given host name.
        #
        def dns_get_mailservers(name)
          dns_get_mx_records(name).map do |record|
            record.exchange.to_s
          end
        end

        #
        # Queries all `NS` DNS records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::NS>]
        #   All `NS` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/NS
        #
        def dns_get_ns_records(name)
          dns_get_records(name,:ns)
        end

        #
        # Queries the nameservers for the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<String>]
        #   The host names of the nameservers serving the given host name.
        #
        def dns_get_nameservers(name)
          dns_get_ns_records(name).map do |record|
            record.name.to_s
          end
        end

        #
        # Queries the first `PTR` DNS record for the IP address.
        #
        # @param [String] ip
        #   The IP address to query.
        #
        # @return [Resolv::DNS::Resource::PTR, nil]
        #   The first `PTR` DNS record of the host name or `nil` if the host
        #   name has no `PTR` records.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/PTR
        #
        def dns_get_ptr_record(ip)
          dns_get_record(ip,:ptr)
        end

        #
        # Queries the `PTR` host name for the IP address.
        #
        # @param [String] ip
        #   The IP address to query.
        #
        # @return [String, nil]
        #   The host name that points to the given IP.
        #
        def dns_get_ptr_name(ip)
          if (record = dns_get_ptr_record(ip))
            record.name.to_s
          end
        end

        #
        # Queries all `PTR` DNS records for the IP address.
        #
        # @param [String] ip
        #   The IP address to query.
        #
        # @return [Array<Resolv::DNS::Resource::PTR>]
        #   All `PTR` DNS records for the given IP.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/PTR
        #
        def dns_get_ptr_records(ip)
          dns_get_records(ip,:ptr)
        end

        #
        # Queries all `PTR` names for the IP address.
        #
        # @param [String] ip
        #   The IP address to query.
        #
        # @return [Array<String>]
        #   The `PTR` names for the given IP.
        #
        def dns_get_ptr_names(ip)
          dns_get_ptr_records(ip).map do |record|
            record.name.to_s
          end
        end

        #
        # Queries the first `SOA` DNS record belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::SOA, nil]
        #   The first `SOA` DNS record for the host name or `nil` if the host
        #   name has no `SOA` records.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/SOA
        #
        def dns_get_soa_record(name)
          dns_get_record(name,:soa)
        end

        #
        # Queiries the first `TXT` DNS record belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Resolv::DNS::Resource::TXT, nil]
        #   The first `TXT` DNS record for the host name or `nil` if the host
        #   name has no `TXT` records.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/TXT
        #
        def dns_get_txt_record(name)
          dns_get_record(name,:txt)
        end

        #
        # Queries the first `TXT` string belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [String, nil]
        #   The first `TXT` string belonging to the host name or `nil` if the
        #   host name has no `TXT` records.
        #
        def dns_get_txt_string(name)
          if (record = dns_get_txt_record(name))
            # TODO
          end
        end

        #
        # Queries all `TXT` DNS records belonging to the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<Resolv::DNS::Resource::TXT>]
        #   All of the `TXT` DNS records belonging to the host name.
        #
        # @see https://rubydoc.info/stdlib/resolv/Resolv/DNS/Resource/TXT
        #
        def dns_get_txt_records(name)
          dns_get_records(name,:txt)
        end

        #
        # Queries all of the `TXT` string values of the host name.
        #
        # @param [String] name
        #   The host name to query.
        #
        # @return [Array<String>]
        #   All `TXT` string values belonging of the host name.
        #
        def dns_get_txt_strings(name)
          dns_get_text_records(name).map do |record|
            # TODO
          end
        end
      end
    end
  end
end
