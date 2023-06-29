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

require 'ronin/recon/value/parser'

module Ronin
  module Recon
    #
    # Represents an input file of values to recon.
    #
    class InputFile

      # The path to the input file.
      #
      # @return [String]
      attr_reader :path

      #
      # Initializes the input file.
      #
      # @param [String] path
      #   The input file path.
      #
      def initialize(path)
        @path = path
      end

      #
      # Opens the input file.
      #
      # @param [String] path
      #   The input file path.
      #
      # @see #initialize
      #
      def self.open(path)
        new(path)
      end

      #
      # Enumerates over every value in the input file.
      #
      # @yield [value]
      #   If a block is given, it will be passed each parsed value.
      #
      # @yieldparam [Values::Domain, Values::Host, Values::IP, Values::IPRange, Values::Website] value
      #   A parsed value from the input file.
      #
      # @return [Enumerator]
      #   If no block is given, then an Enumerator will be returned.
      #
      def each
        return enum_for unless block_given?

        File.open(@path) do |file|
          file.each_line(chomp: true) do |line|
            yield Value.parse(line)
          end
        end
      end

    end
  end
end
