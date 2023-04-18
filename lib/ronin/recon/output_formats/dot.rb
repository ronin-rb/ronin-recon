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

require 'set'

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

          @values = Set.new

          @io.puts "digraph {"
        end

        #
        # Returns the descriptive type name for the value object.
        #
        # @param [Value] value
        #   The value object.
        #
        # @return [String]
        #   The type name for the value object.
        #
        # @raise [NotImplementedError]
        #   The given value object was not supported.
        #
        def value_type(value)
          case value
          when Values::Domain     then "Domain"
          when Values::Mailserver then "Mailserver"
          when Values::Nameserver then "Nameserver"
          when Values::Host       then "Host"
          when Values::IP         then "IP address"
          when Values::IPRange    then "IP range"
          when Values::OpenPort   then "Open #{value.protocol.upcase} Port"
          when Values::URL        then "URL"
          when Values::Website    then "Website"
          when Values::Wildcard   then "Wildcard"
          else
            raise(NotImplementedError,"value class #{value.class} not supported")
          end
        end

        #
        # Writes a value to the GraphViz DOT output stream as a node
        # declaration.
        #
        # @param [Value] value
        #   The value object to write.
        #
        def write_value(value)
          name  = value.to_s
          label = "#{value_type(value)}\n#{name}"

          @io.puts "\t#{name.inspect} [label=#{label.inspect}]"
        end

        #
        # Appends a value and it's parent value to the GraphViz DOT output
        # stream.
        #
        # @param [Value] value
        #   The value to append.
        #
        # @param [Value] parent
        #   The parent value of the given value.
        # 
        # @return [self]
        #
        def write(value,parent)
          write_value(value)  if @values.add?(value)
          write_value(parent) if @values.add?(parent)

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
