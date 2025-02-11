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

require_relative 'text'

require 'ronin/core/cli/logging'

module Ronin
  module Recon
    class CLI
      #
      # Helper methods for printing {Values Value} objects.
      #
      module Printing
        include Text
        include Core::CLI::Logging

        #
        # Prints a newly discovered value.
        #
        # @param [Value] value
        #   The value to print.
        #
        # @param [Value, nil] parent
        #   The optional parent value.
        #
        # @raise [NotImplementedError]
        #   The given value object was not supported.
        #
        def print_value(value,parent=nil)
          if stdout.tty?
            if parent
              log_info "Found new #{format_value(value)} for #{format_value(parent)}"
            else
              log_info "Found new #{format_value(value)}"
            end
          else
            puts value
          end
        end
      end
    end
  end
end
