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

require 'ronin/recon/value'

module Ronin
  module Recon
    module Values
      #
      # Represents a discovered open port.
      #
      # @api public
      #
      class OpenPort < Value

        # The IP address that the open port listens on.
        #
        # @return [String]
        attr_reader :address

        # The port number.
        #
        # @return [Integer]
        attr_reader :number

        # The optional hostname associated with the address.
        #
        # @return [String, nil]
        attr_reader :host

        # The protocol of the port.
        #
        # @return [:tcp, :udp] protocol
        attr_reader :protocol

        # The optional service information.
        #
        # @return [String, nil] service
        attr_reader :service

        # Indiciates whether the open port uses SSL.
        #
        # @return [Boolean]
        attr_reader :ssl

        #
        # Initializes the open port.
        #
        # @param [String] address
        #   The IP address for the open port.
        #
        # @param [Integer] number
        #   The port number.
        #
        # @param [String, nil] host
        #   The optional hostname associated with the address.
        #
        # @param [:tcp, :udp] protocol
        #   The protocol of the port.
        #
        # @param [String, nil] service
        #   The optional service information.
        #
        # @param [Boolean] ssl
        #   Indicates that the open port uses SSL/TLS.
        #
        def initialize(address,number, host:     nil,
                                       protocol: :tcp,
                                       service:  nil,
                                       ssl:      false)
          @address  = address
          @number   = number
          @host     = host
          @protocol = protocol
          @service  = service
          @ssl      = ssl
        end

        #
        # Determines whether the open port uses SSL/TLS.
        #
        # @return [Boolean]
        #
        def ssl?
          @ssl
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) &&
            @address  == other.address &&
            @number   == other.number &&
            @protocol == other.protocol &&
            @service  == other.service &&
            @ssl      == other.ssl
        end

        #
        # The "hash" value of the open port.
        #
        # @return [Integer]
        #
        def hash
          [self.class, @address, @number, @protocol, @service, @ssl].hash
        end

        #
        # Converts the open port into a String.
        #
        # @return [String]
        #   The hot-name/IP and port number.
        #
        def to_s
          "#{@address}:#{@number}"
        end

        #
        # Converts the open port into an Integer.
        #
        # @return [Integer]
        #   The port {#number}.
        #
        def to_i
          @number.to_i
        end

        alias to_int to_i

        #
        # Coerces the open port value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          hash = {
            type:     :open_port,
            address:  @address,
            protocol: @protocol,
            number:   @number
          }

          hash[:service] = @service if @service
          hash[:ssl]     = @ssl     if @ssl

          return hash
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:open_port]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :open_port
        end

      end
    end
  end
end
