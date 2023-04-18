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

require 'ronin/recon/output_formats/output_file'

require 'json'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a newline deliminated JSON (`.ndjson`) output stream.
      #
      class NDJSON < OutputFile

        #
        # Appends a value to the NDJSON stream.
        #
        # @param [Values::Value] value
        #   The value to append.
        # 
        # @return [self]
        #
        def write(value)
          JSON.dump(value.to_json,@file)
          @file.flush
        end

      end
    end
  end
end
