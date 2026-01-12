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

module Ronin
  module Recon
    module Message
      #
      # Indicates that a job encountered an exception.
      #
      # @api private
      #
      class JobFailed

        # The worker object.
        #
        # @return [Worker]
        attr_reader :worker

        # The input value object.
        #
        # @return [Value]
        attr_reader :value

        # The exception.
        #
        # @return [StandardError]
        attr_reader :exception

        #
        # Initializes the message.
        #
        # @param [Worker] worker
        #   The worker object.
        #
        # @param [Value] value
        #   The input value object.
        #
        # @param [StandardError] exception
        #   The exception object.
        #
        def initialize(worker,value,exception)
          @worker    = worker
          @value     = value
          @exception = exception

          freeze
        end

      end
    end
  end
end
