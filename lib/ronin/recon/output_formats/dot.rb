# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'ronin/core/output_formats/output_file'
require 'ronin/recon/output_formats/graph_format'
require 'ronin/recon/values/domain'
require 'ronin/recon/values/mailserver'
require 'ronin/recon/values/nameserver'
require 'ronin/recon/values/host'
require 'ronin/recon/values/ip'
require 'ronin/recon/values/ip_range'
require 'ronin/recon/values/open_port'
require 'ronin/recon/values/email_address'
require 'ronin/recon/values/cert'
require 'ronin/recon/values/url'
require 'ronin/recon/values/website'
require 'ronin/recon/values/wildcard'

require 'set'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a GraphViz DOT (`.dot`) output format.
      #
      class Dot < Core::OutputFormats::OutputFile

        include GraphFormat

        #
        # Initializes the GraphViz DOT (`.dot`) output format.
        #
        # @param [IO] io
        #   The output stream to write to.
        #
        def initialize(io)
          super(io)

          @io.puts "digraph {"
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
          when Values::Domain       then "Domain"
          when Values::Mailserver   then "Mailserver"
          when Values::Nameserver   then "Nameserver"
          when Values::Host         then "Host"
          when Values::IP           then "IP address"
          when Values::IPRange      then "IP range"
          when Values::OpenPort     then "Open #{value.protocol.upcase} Port"
          when Values::EmailAddress then "Email Address"
          when Values::Cert         then "SSL/TLS Cert"
          when Values::URL          then "URL"
          when Values::Website      then "Website"
          when Values::Wildcard     then "Wildcard"
          else
            raise(NotImplementedError,"value class #{value.class} not supported")
          end
        end

        #
        # Returns the body text for the value object.
        #
        # @param [Values::Value] value
        #   The value object.
        #
        # @return [String]
        #   The body text for the value object.
        #
        def value_text(value)
          case value
          when Values::URL
            "#{value.status} #{value}"
          when Values::Cert
            value.subject.to_h.map { |k,v| "#{k}: #{v}\n" }.join
          else
            value.to_s
          end
        end

        #
        # Writes a value to the GraphViz DOT output stream as a node
        # declaration.
        #
        # @param [Values::Value] value
        #   The value object to write.
        #
        def <<(value)
          name  = value.to_s
          label = "#{value_type(value)}\n#{value_text(value)}"

          @io.puts "\t#{name.inspect} [label=#{label.inspect}]"
          @io.flush
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
        def []=(value,parent)
          @io.puts "\t#{parent.to_s.inspect} -> #{value.to_s.inspect}"
          @io.flush
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
