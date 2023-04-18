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

require 'csv'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a CSV (`.csv`) output stream.
      #
      class CSV < OutputFile

        #
        # Maps a value to a type Symbol.
        #
        # @param [Value] value
        #   The value.
        #
        # @return [:domain, :mailserver, :nameserver, :host, :ip, :ip_range, :open_port, :url, :website, :wildcard]
        #   The type Symbol.
        #
        # @raise [NotImplementedError]
        #   The given value object was not supported.
        #
        def value_type(value)
          case value
          when Values::Domain     then :domain
          when Values::Mailserver then :mailserver
          when Values::Nameserver then :nameserver
          when Values::Host       then :host
          when Values::IP         then :ip
          when Values::IPRange    then :ip_range
          when Values::OpenPort   then :open_port
          when Values::URL        then :url
          when Values::Website    then :website
          when Values::Wildcard   then :wildcard
          else
            raise(NotImplementedError,"value class #{value.class} not supported")
          end
        end

        #
        # Appends a value to the CSV stream.
        #
        # @param [Value] value
        #   The value to append.
        # 
        def write(value,parent)
          @file.write(CSV.generate_line(value_type(value),value))
        end

      end
    end
  end
end
