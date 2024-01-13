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

module Ronin
  module Recon
    module Message
      #
      # Indicates that a worker has started a job.
      #
      # @api private
      #
      class JobStarted

        # The worker object.
        #
        # @return [Worker]
        attr_reader :worker

        # The input value object.
        #
        # @return [Values::Value]
        attr_reader :value

        #
        # Initializes the message.
        #
        # @param [Worker] worker
        #   The worker object.
        #
        # @param [Values::Value] value
        #   The input value object.
        #
        def initialize(worker,value)
          @worker = worker
          @value  = value

          freeze
        end

      end
    end
  end
end
