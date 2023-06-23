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

require 'json'
require 'csv'

module Ronin
  module Recon
    module Values
      #
      # Base class for all {Values} classes.
      #
      # @abstract
      #
      class Value

        #
        # Returns the type or kind of recon value.
        #
        # @return [Symbol]
        #
        # @note
        #   This is used internally to map a recon value class to a printable
        #   type.
        #
        # @abstract
        #
        # @api private
        #
        def self.value_type
          raise(NotImplementedError,"#{self}.value_type was not defined")
        end

        #
        # Coerces the value into JSON.
        #
        # @return [Hash{Symbol => Object}]
        #   The Ruby Hash that will be converted into JSON.
        #
        # @abstract
        #
        def as_json
          raise(NotImplementedError,"#{self.class}#as_json was not implemented")
        end

        #
        # Converts the value to a String.
        #
        # @return [String]
        #   The string value of the value.
        #
        # @abstract
        #
        def to_s
          raise(NotImplementedError,"#{self.class}#to_s was not implemented")
        end

        #
        # Converts the value into JSON.
        #
        # @param [Hash, nil] options
        #   Additional options for `JSON.generate`.
        #
        # @param [Array] args
        #   Additional arguments for `Hash#to_json`.
        #
        # @return [String]
        #   The raw JSON string.
        #
        def to_json(*args)
          as_json.to_json(*args)
        end

        #
        # Converts the value to a CSV row.
        #
        # @return [String]
        #   The CSV row.
        #
        def to_csv
          CSV.generate_line([self.class.value_type,to_s])
        end

      end
    end
  end
end
