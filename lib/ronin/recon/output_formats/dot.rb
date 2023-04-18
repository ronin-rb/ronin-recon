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

require 'set'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a GraphViz DOT (`.dot`) output format.
      #
      class Dot < OutputFile

        #
        # Initializes the GraphViz DOT (`.dot`) output format.
        #
        # @param [String] path
        #   The `.dot` file to write to.
        #
        def initialize(path)
          super(path)

          @file.puts "digraph {"
        end

        #
        # Returns the descriptive type name for the value object.
        #
        # @param [Values::Value] value
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
        # @param [Values::Value] value
        #   The value object to write.
        #
        def write_value(value)
          name  = value.to_s
          label = "#{value_type(value)}\n#{name}"

          @file.puts "\t#{name.inspect} [label=#{label.inspect}]"
          @file.flush
        end

        #
        # Appends a value and it's parent value to the GraphViz DOT output
        # stream.
        #
        # @param [Values::Value] value
        #   The value to append.
        #
        # @param [Values::Value] parent
        #   The parent value of the given value.
        # 
        # @return [self]
        #
        def write_connection(value,parent)
          @file.puts "\t#{parent.to_s.inspect} -> #{value.to_s.inspect}"
          @file.flush
        end

        #
        # Writes the complete JSON Array of values and closes the IO stream.
        #
        def close
          @file.puts "}"

          super
        end

      end
    end
  end
end
