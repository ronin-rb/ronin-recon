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

module Ronin
  module Recon
    module OutputFormats
      #
      # Base class for all {OutputFormats} classes.
      #
      # @abstract
      #
      class OutputFormat

        #
        # Initializes the output file.
        #
        # @param [IO] io
        #   The IO stream to write to.
        #
        # @api semipublic
        #
        def initialize(io)
          @io = io
        end

        #
        # Opens an output file.
        #
        # @param [String] path
        #   The path to the new output file.
        #
        # @yield [output_file]
        #   If a block is given, then it will be passed the opened output file.
        #   Once the block has returned, the output file will automatically be
        #   closed and `nil` will be returned.
        #
        # @yieldparam [OutputFile] output_file
        #   The opened output file.
        #
        # @return [OutputFile, nil]
        #   The newly opened output file, if no block was given.
        #
        # @api public
        #
        def self.open(path,&block)
          output_file = new(File.new(path,'w'))

          if block_given?
            yield output_file
            output_file.close
          else
            return output_file
          end
        end

        #
        # Writes a value to the output stream.
        #
        # @param [Value] value
        #   The value to write.
        #
        # @return [self]
        #
        # @abstract
        #
        def <<(value)
          raise(NotImplementedError,"#{self}#<< was not implemented")
        end

        #
        # Closes the output stream.
        #
        # @api public
        #
        def close
          @io.close unless @io.tty?
        end

      end
    end
  end
end
