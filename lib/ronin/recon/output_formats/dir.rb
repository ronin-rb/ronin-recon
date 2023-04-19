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
require 'ronin/recon/values'

require 'fileutils'
require 'set'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents an output directory.
      #
      class Dir < OutputFormat

        # The set of previously seen values.
        #
        # @return [Set<Value>]
        attr_reader :values

        # Mapping of value classes to file names.
        VALUE_FILE_NAMES = {
          Values::Domain     => 'domains.txt',
          Values::Mailserver => 'mailservers.txt',
          Values::Nameserver => 'nameservers.txt',
          Values::Host       => 'hosts.txt',
          Values::Wildcard   => 'wildcards.txt',
          Values::IP         => 'ips.txt',
          Values::IPRange    => 'ip_ranges.txt',
          Values::OpenPort   => 'open_ports.txt',
          Values::Cert       => 'certs.txt',
          Values::Website    => 'websites.txt',
          Values::URL        => 'urls.txt'
        }

        #
        # Initializes the list output format.
        #
        # @param [String] path
        #   The output file path.
        #
        def initialize(path)
          super(path)

          FileUtils.mkdir_p(@path)
          @files = VALUE_FILE_NAMES.transform_values do |file_name|
            File.open(File.join(@path,file_name),'w')
          end
        end

        #
        # Writes a new value to it's specific file.
        #
        # @param [Values::Value] value
        #   The value to write.
        #
        def write_value(value)
          file = @files.fetch(value.class) do
            raise(NotImplementedError,"unsupported value class: #{value.inspect}")
          end

          file.puts(value)
          file.flush
        end

        #
        # Closes the output files.
        #
        def close
          @files.each_value(&:close)
        end

      end
    end
  end
end
