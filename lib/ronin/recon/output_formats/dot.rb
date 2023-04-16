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

require 'ronin/recon/output_format'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a GraphViz DOT (`.dot`) output format.
      #
      class Dot < OutputFormat

        #
        # Initializes the GraphViz DOT (`.dot`) output format.
        #
        # @param [IO] io
        #   The IO stream to write to.
        #
        def initialize(io)
          super(io)

          @io.puts "digraph {"
        end

        #
        # Appends a value to the GraphViz DOT output stream.
        #
        # @param [Value] value
        #   The value to append.
        #
        # @param [Value] parent
        # 
        # @return [self]
        #
        def write(value,parent)
          @io.puts "\t#{parent.to_s.inspect} -> #{value.to_s.inspect}"
        end

        #
        # Writes the complete JSON Array of values and closes the IO stream.
        #
        def close
          @io.puts "}"

          super
        end

      end
    end
  end
end
