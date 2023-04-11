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

require 'ronin/recon/value'
require 'ronin/recon/values/host'
require 'ronin/recon/values/domain'
require 'ronin/recon/values/ip'

module Ronin
  module Recon
    module Values
      #
      # Represents a discovered open port.
      #
      # @api public
      #
      class OpenPort < Value

        # The host name or IP address for the open port.
        #
        # @return [Host, Domain, IP]
        attr_reader :host

        # The port number.
        #
        # @return [Integer]
        attr_reader :number

        # The protocol of the port.
        #
        # @return [:tcp, :udp] protocol
        attr_reader :protocol

        # The optional service information.
        #
        # @return [Software, nil] service
        attr_reader :service

        #
        # Initializes the open port.
        #
        # @param [Host, Domain, IP] host
        #   The host name or IP address for the open port.
        #
        # @param [Integer] number
        #   The port number.
        #
        # @param [:tcp, :udp] protocol
        #   The protocol of the port.
        #
        # @param [Software, nil] service
        #   The optional service information.
        #
        def initialize(host,number, protocol: :tcp, service: nil)
          @host     = host
          @number   = number
          @protocol = protocol
          @service  = service
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
            @host     == other.host &&
            @number   == other.number &&
            @protocol == other.protocol &&
            @service  == other.service
        end

        #
        # The "hash" value of the open port.
        #
        # @return [Integer]
        #
        def hash
          [self.class, @host, @number, @protocol, @service].hash
        end

        #
        # @return [(String, Integer)]
        #
        def to_a
          [@host.to_s, @number.to_i]
        end

        alias to_ary to_a

        #
        # Converts the open port into a String.
        #
        # @return [String]
        #   The hot-name/IP and port number.
        #
        def to_s
          "#{@host}:#{@number}"
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

      end
    end
  end
end
