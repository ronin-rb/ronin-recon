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

require 'json'

module Ronin
  module Recon
    module Values
      #
      # Base class for all {Values} classes.
      #
      # @abstract
      #
      class Value

        #
        # Coerces the value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        # @abstract
        #
        def as_json
          raise(NotImplementedError,"#{self.class}#as_json was not implemented")
        end

        #
        # Converts the value to a String.
        #
        # @return [String]
        #   The string value of the value.
        #
        # @abstract
        #
        def to_s
          raise(NotImplementedError,"#{self.class}#to_s was not implemented")
        end

        #
        # Converts the value into JSON.
        #
        # @return [String]
        #   The raw JSON string.
        #
        def to_json
          as_json.to_json
        end

      end
    end
  end
end
