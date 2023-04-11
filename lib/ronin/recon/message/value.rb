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
    module Message
      #
      # Represents either an input or output value.
      #
      # @api private
      #
      class Value

        # The value's object.
        #
        # @return [Object]
        attr_reader :value

        # The associated parent value.
        #
        # @return [Value, nil]
        attr_reader :parent

        # The depth of the value in relation to the input value.
        #
        # @return [Integer]
        attr_reader :depth

        # The ID of the recond worker which produced the value.
        #
        # @return [Worker, nil]
        attr_reader :worker

        #
        # Initializes the recon value.
        #
        # @param [Value, nil] parent
        #   The associated parent value.
        #
        # @param [Integer] depth
        #   The depth of the value object.
        #
        # @param [Worker, nil] worker
        #   The worker object, if the value object is an output value produced
        #   by the worker object.
        #
        def initialize(value, parent: nil, depth: 0, worker: nil)
          @value  = value
          @parent = parent
          @depth  = depth
          @worker = worker

          freeze
        end

      end
    end
  end
end
