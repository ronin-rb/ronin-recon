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

require_relative '../value'

require 'uri'

module Ronin
  module Recon
    module Values
      #
      # Represents a WebSocket.
      #
      # @api public
      #
      # @since 0.2.0
      #
      class WebSocket < Value

        # The parsed URI.
        #
        # @return [URI::WS, URI::WSS]
        attr_reader :uri

        #
        # Initializes the WebSocket value.
        #
        # @param [URI::WS, URI::WSS, String] url
        #
        def initialize(url)
          @uri = URI(url)
        end

        #
        # Indicates whether the WebSocket uses `ws://` or `wss://`.
        #
        # @return ['ws', 'wss']
        #
        def scheme
          @uri.scheme
        end

        #
        # The WebSocket's hostname.
        #
        # @return [String]
        #
        def host
          @uri.host
        end

        #
        # The WebSocket's port number.
        #
        # @return [Integer]
        #
        def port
          @uri.port
        end

        #
        # The WebSocket's path.
        #
        # @return [String]
        #
        def path
          @uri.path
        end

        #
        # The WebSocket's query
        #
        # @return [String]
        #
        def query
          @uri.query
        end

        #
        # Initializes the 'ws://' WebSocket.
        #
        # @param [String] host
        #   The WebSocket's host.
        #
        # @param [Integer] port
        #   The WebSocket's port.
        #
        # @param [String] path
        #   The WebSocket's path.
        #
        # @param [String] query
        #   The WebSocket's query.
        #
        def self.ws(host,port=80,path=nil,query=nil)
          new(URI::WS.build(host: host, port: port, path: path, query: query))
        end

        #
        # Initializes the 'wss://' WebSocket.
        #
        # @param [String] host
        #   The WebSocket's host.
        #
        # @param [Integer] port
        #   The WebSocket's port.
        #
        # @param [String] path
        #   The WebSocket's path.
        #
        # @param [String] query
        #   The WebSocket's query.
        #
        def self.wss(host,port=443,path=nil,query=nil)
          new(URI::WSS.build(host: host, port: port, path: path, query: query))
        end

        #
        # Compares the WebSocket to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          self.class == other.class &&
            scheme == other.scheme &&
            host == other.host &&
            port == other.port &&
            path == other.path &&
            query == other.query
        end

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Imdicates whether the other value same as {WebSocket}
        #
        def ===(other)
          case other
          when WebSocket
            eql?(other)
          else
            false
          end
        end

        #
        # The "hash" value of the WebSocket.
        #
        # @return [Integer]
        #   The hash value of {#scheme}, {#host}, {#port}, {#path} and {#query}.
        #
        def hash
          [self.class, scheme, host, port, path, query].hash
        end

        # Mapping of {#scheme} values to URI classes.
        #
        # @api private
        URI_CLASSES = {
          'wss' => URI::WSS,
          'ws'  => URI::WS
        }

        #
        # Converts the WebSocket to URI.
        #
        # @return [URI::WS, URI::WSS]
        #   The URI object for the website.
        #
        def to_uri
          @uri
        end

        #
        # Converts the WebSocket to a String.
        #
        # @return [String]
        #   The base URL value for the WebSocket.
        #
        def to_s
          @uri.to_s
        end

        #
        # Coerces the WebSocket value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {
            type:   :web_socket,
            scheme: scheme,
            host:   host,
            port:   port,
            path:   path,
            query:  query
          }
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:web_socket]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :web_socket
        end
      end
    end
  end
end
