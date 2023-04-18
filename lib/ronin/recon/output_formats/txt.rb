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

require 'ronin/recon/output_formats/output_format'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a plain-text (`.txt`) output stream.
      #
      class TXT < OutputFormat

        #
        # Appends a value to the TXT output stream.
        #
        # @param [Value] value
        #   The value to append.
        # 
        # @return [self]
        #
        def write(value,parent)
          @io.puts("#{value} <- #{parent}")
        end

      end
    end
  end
end
