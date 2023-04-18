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

require 'ronin/recon/values/value'

require 'uri'

module Ronin
  module Recon
    module Values
      #
      # Represents a discovered URL.
      #
      # @api public
      #
      class URL < Value

        # The parsed URI.
        #
        # @return [URI::HTTP, URI::HTTPS]
        attr_reader :uri

        #
        # Initializes the URL object.
        #
        # @param [URI::HTTP, URI::HTTPS, String] url
        #
        def initialize(url)
          @uri = URI(url)
        end

        #
        # Compares the value to another value.
        #
        # @param [Values::Value] other
        #
        # @return [Boolean]
        #
        def eql?(other)
          other.kind_of?(self.class) && @uri == other.uri
        end

        #
        # The "hash" value of the URL.
        #
        # @return [Integer]
        #   The hash value of {#uri}.
        #
        def hash
          [self.class, @uri].hash
        end

        alias to_uri uri

        #
        # Converts the URL object to a String.
        #
        # @return [String]
        #   The URL string.
        #
        def to_s
          @uri.to_s
        end

        alias to_str to_s

        #
        # Coerces the URL value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :uri, url: @url.to_s}
        end

      end
    end
  end
end
