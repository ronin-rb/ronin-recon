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

require 'ronin/recon/values'

require 'ronin/db'

module Ronin
  module Recon
    module Importer
      #
      # Imports a value into the database.
      #
      # @param [Value] value
      #   A discovered recon value to import.
      #
      # @return [Ronin::DB::HostName,
      #          Ronin::DB::IPAddress,
      #          Ronin::DB::OpenPort,
      #          Ronin::DB::URL]
      #   The imported record.
      #
      def self.import_value(value)
        case value
        when Values::Host     then import_host_name(value.name)
        when Values::IP       then import_ip_address(value.address)
        when Values::OpenPort then import_open_port(value)
        when Values::URL      then import_url(value.string)
        end
      end

      #
      # Imports a host value.
      #
      # @param [String] host_name
      #   The host name to import.
      #
      # @return [Ronin::DB::HostName]
      #   The imported host name record.
      #
      def self.import_host_name(host_name)
        DB::HostName.transaction do
          DB::HostName.find_or_import(host_name)
        end
      end

      #
      # Imports a IP address.
      #
      # @param [String] address
      #   The IP address to import.
      #
      # @return [Ronin::DB::IPAddress]
      #   The imported IP address record.
      #
      def self.import_ip_address(address)
        DB::IPAddress.transaction do
          DB::IPAddress.find_or_import(address)
        end
      end

      #
      # Imports a URL.
      #
      # @param [String] url
      #   The URL string to import.
      #
      # @return [Ronin::DB::URL]
      #   The imported URL record.
      #
      def self.import_url(url)
        DB::URL.transaction do
          DB::URL.find_or_import(url)
        end
      end

      #
      # Imports a port number.
      #
      # @param [Integer] number
      #   The port number to import.
      #
      # @return [Ronin::DB::Port]
      #   The imported port record.
      #
      def self.import_port(protocol,number)
        DB::Port.transaction do
          DB::Port.find_or_create_by(
            protocol: protocol,
            number:   number
          )
        end
      end

      #
      # Imports a service name.
      #
      # @param [String] service
      #   The service name to import.
      #
      # @return [Ronin::DB::Service]
      #   The imported service record.
      #
      def self.import_service(service)
        DB::Service.transaction do
          DB::Service.find_or_import(service)
        end
      end

      #
      # Imports an open port value.
      #
      # @param [Values::OpenPort] open_port
      #   The open port value to import.
      #
      # @return [Ronin::DB::Open_port]
      #   The imported open port record.
      #
      def self.import_open_port(open_port)
        imported_ip_address = import_ip_address(open_port.address)
        imported_port       = import_port(open_port.protocol,open_port.number)
        imported_service    = import_service(open_port.service)
        imported_open_port  = DB::OpenPort.transaction do
                                DB::OpenPort.find_or_create_by(
                                  ip_address: imported_ip_address,
                                  port:       imported_port,
                                  service:    imported_service
                                )
                              end

        return imported_open_port
      end
    end
  end
end
