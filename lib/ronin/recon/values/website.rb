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
require 'ronin/recon/values/url'

require 'uri'

module Ronin
  module Recon
    module Values
      #
      # Represents a discovered website (ex: `https://example.com`).
      #
      # @api public
      #
      class Website < Value

        # Indicates whether the website uses `http://` or `https://`.
        #
        # @return ['http', 'https']
        attr_reader :scheme

        # The website's host name.
        #
        # @return [String]
        attr_reader :host

        # The website's port number.
        #
        # @return [Integer]
        attr_reader :port

        #
        # Initializes the website.
        #
        # @param ['http', 'https'] scheme
        #   Indicates whether the website uses `http://` or `https://`.
        #
        # @param [String] host
        #   The website's host name.
        #
        # @param [Integer] port
        #   The website's port number.
        #
        def initialize(scheme,host,port)
          @scheme = scheme
          @host   = host
          @port   = port
        end

        #
        # Initializes a new `http://` website.
        #
        # @param [String] host
        #   The website's host name.
        #
        # @param [Integer] port
        #   The website's port number.
        #
        # @return [Website]
        #   The new website value.
        #
        def self.http(host,port=80)
          new('http',host,port)
        end

        #
        # Initializes a new `https://` website.
        #
        # @param [String] host
        #   The website's host name.
        #
        # @param [Integer] port
        #   The website's port number.
        #
        # @return [Website]
        #   The new website value.
        #
        def self.https(host,port=443)
          new('https',host,port)
        end

        #
        # Parses a URL.
        #
        # @param [String] url
        #   The URL string to parse.
        #
        # @return [Website]
        #   The parsed website object.
        #
        def self.parse(url)
          uri = URI.parse(url)

          Values::Website.new(uri.scheme,uri.host,uri.port)
        end

        #
        # Compares the value to another value.
        #
        # @param [Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          self.class == other.class &&
            @scheme == other.scheme &&
            @host   == other.host &&
            @port   == other.port
        end

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Imdicates whether the other value is either the same {Website} or
        #   a {URL} with the same {#scheme}, {#host}, and {#port} as the
        #   website.
        #
        def ===(other)
          case other
          when Website
            self == other
          when URL
            @scheme == other.scheme &&
              @host == other.host &&
              @port == other.port
          else
            false
          end
        end

        #
        # The "hash" value of the wildcard host name.
        #
        # @return [Integer]
        #   The hash value of {#host} and {#port}.
        #
        def hash
          [self.class, @scheme, @host, @port].hash
        end

        # Mapping of {#scheme} values to URI classes.
        #
        # @api private
        URI_CLASSES = {
          'https' => URI::HTTPS,
          'http'  => URI::HTTP
        }

        #
        # Converts the website into a URI.
        #
        # @return [URI::HTTP, URI::HTTPS]
        #   The URI object for the website.
        #
        def to_uri
          URI_CLASSES.fetch(@scheme).build(host: @host, port: @port, path: '/')
        end

        #
        # Converts the website to a String.
        #
        # @return [String]
        #   The base URL value for the website.
        #
        def to_s
          if ((@scheme == 'https') && (@port != 443)) ||
             ((@scheme == 'http')  && (@port != 80))
            "#{@scheme}://#{@host}:#{@port}"
          else
            "#{@scheme}://#{@host}"
          end
        end

        #
        # Coerces the website value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :website, scheme: @scheme, host: @host, port: @port}
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:website]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @api private
        #
        def self.value_type
          :website
        end

      end
    end
  end
end
