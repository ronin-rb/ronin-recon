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

require 'async/http'
require 'set'

module Ronin
  module Recon
    module Mixins
      #
      # Mixin which adds methods for performing async HTTP requests.
      #
      # @api public
      #
      module HTTP
        # HTTP status codes that indicate a valid route.
        VALID_STATUS_CODES = Set[
          200, # OK
          201, # Created
          202, # Accepted
          203, # Non-Authoritative Information
          204, # No Content
          205, # Reset Content
          206, # Partial Content
          207, # Multi-Status
          208, # Already Reported
          226, # IM Used
          405, # Method Not Allowed
          409, # Conflict
          415, # Unsupported Media Type
          422, # Unprocessable Content
          423, # Locked
          424, # Failed Dependency
          451, # Unavailable For Legal Reasons
          500  # Internal Server Error
        ]
      end
    end
  end
end
