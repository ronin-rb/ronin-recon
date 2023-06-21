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

require 'ronin/recon/values/nameserver'

module Ronin
  module Recon
    module Values
      #
      # Represents a discovered mailserver.
      #
      # @api public
      #
      class Mailserver < Host

        #
        # Coerces the mailserver value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        def as_json
          {type: :mailserver, name: @name}
        end

        #
        # Returns the type or kind of recon value.
        #
        # @return [:mailserver]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @abstract
        #
        # @api private
        #
        def self.value_type
          :mailserver
        end

      end
    end
  end
end
