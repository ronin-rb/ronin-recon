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

require 'set'

module Ronin
  module Recon
    #
    # Represents a directed graph of discovered values and their parent values.
    #
    class Graph

      # The nodes in the graph.
      #
      # @return [Set<Value>]
      attr_reader :nodes

      # The edges between nodes in the graph.
      #
      # @return [Hash{Value => Set<Value>}]
      attr_reader :edges

      #
      # Initializes the graph.
      #
      # @api private
      #
      def initialize
        @nodes = Set.new
        @edges = {}
      end

      #
      # Adds a value to the graph, if it already hasn't been added.
      #
      # @param [Values::Value] new_value
      #   The new value node to add.
      #
      # @return [Boolean]
      #   Indicates whether the value node was successfully added to the graph,
      #   or if the value node was already added to the graph.
      #
      # @api private
      #
      def add_node(new_value)
        !@nodes.add?(new_value).nil?
      end

      #
      # Adds a value to the graph, if it already hasn't been added.
      #
      # @param [Values::Value] new_value
      #   The new value node to add.
      #
      # @param [Value, nil] parent_value
      #   The parent value node of the new value node.
      #
      # @return [Boolean]
      #   Indicates whether the value node was successfully added to the graph,
      #   or if the value node was already added to the graph.
      #
      # @api private
      #
      def add_edge(new_value,parent_value=nil)
        node_parents= (@edges[new_value] ||= Set.new)
        return node_parents.add?(parent_value)
      end

      #
      # Determines if the value is in the graph.
      #
      # @param [Values::Value] value
      #   The value node.
      #
      # @return [Boolean]
      #   Indicates whether the value exists in the graph or not.
      #
      def include?(value)
        @nodes.include?(value)
      end

      #
      # Fetches the parent value nodes for the value.
      #
      # @param [Values::Value] value
      #   The value node to lookup.
      #
      # @return [Set<Value>, nil]
      #   The set of parent value nodes or `nil` if the value does not exist in
      #   the graph.
      #
      def [](value)
        @edges[value]
      end

    end
  end
end
