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

require_relative 'graph_format'
require_relative 'dot'

require 'ronin/core/output_formats/output_file'
require 'tempfile'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a GraphViz output format.
      #
      class GraphvizFormat < Core::OutputFormats::OutputFile

        include GraphFormat

        # The `.dot` output file.
        #
        # @return [Tempfile]
        attr_reader :dot_file

        # The DOT output format.
        #
        # @return [Dot]
        attr_reader :dot_output

        #
        # Initializes the GraphViz output format.
        #
        # @param [IO] io
        #   The output stream to write to.
        #
        def initialize(io)
          super(io)

          @dot_file   = Tempfile.new(['ronin-recon',"#{format}"])
          @dot_output = Dot.new(@dot_file)
        end

        #
        # The desired GraphViz output format.
        #
        # @return [Symbol]
        #   The output format name.
        #
        # @abstract
        #
        def format
          raise(NotImplementedError,"#{self.class}#format was not defined!")
        end

        #
        # Writes a value to the GraphViz output stream as a node declaration.
        #
        # @param [Value] value
        #   The value object to write.
        #
        def <<(value)
          @dot_output << value
        end

        #
        # Appends a value and it's parent value to the GraphViz output stream.
        #
        # @param [Value] value
        #   The value to append.
        #
        # @param [Value] parent
        #   The parent value of the given value.
        #
        # @return [self]
        #
        def []=(value,parent)
          @dot_output[value] = parent
          return self
        end

        #
        # Closes and generates the GraphViz output file.
        #
        def close
          @dot_output.close

          IO.popen(['dot',"-T#{format}",@dot_file.path]) do |dot_io|
            # relay the `dot` output to the output stream.
            @io.write(dot_io.readpartial(4096)) until dot_io.eof?
          end

          super
        end

      end
    end
  end
end
