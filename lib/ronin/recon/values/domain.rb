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

require 'ronin/recon/values/host'

module Ronin
  module Recon
    module Values
      #
      # Represents a domain name (ex: `example.com`).
      #
      class Domain < Host

        #
        # Case equality method used for fuzzy matching.
        #
        # @param [Value] other
        #   The other value to compare.
        #
        # @return [Boolean]
        #   Imdicates whether the other value is either a {Domain} and has the
        #   same domain name, or a {Host} and shares the same domain name.
        #
        def ===(other)
          case other
          when Domain
            @name == other.name
          when Host
            other.name.end_with?(".#{@name}")
          else
            false
          end
        end

        #
        # Coerces the domain value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :domain, name: @name}
        end

      end
    end
  end
end
