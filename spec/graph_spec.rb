require 'spec_helper'
require 'ronin/recon/graph'

describe Ronin::Recon::Graph do
  subject { described_class.new }
  
  describe "#initialize" do
    it "must initialize #nodes and #edges" do
      expect(subject.nodes).to eq(Set.new)
      expect(subject.edges).to eq({})
    end
  end
  
  describe "#add_node" do
    context "when value node was successfully added" do
      it "must return true" do
        expect(subject.add_node("node_value")).to be(true)
      end

      it "must contain node" do
        subject.add_node("node_value")
        expect(subject.nodes.size).to eq 1
      end
    end

    context "when value node was already added" do
      it "must return false" do
        subject.add_node("node_value")
        expect(subject.add_node("node_value")).to be(false)
      end
    end
  end
  
  describe "#add_edge" do
    context "when node value was successfully added" do
      it "must return true" do
        expect(subject.add_edge("node_value")).to be(true)
      end
    end

    context "when node value was already added" do
      it "must return false" do
        subject.add_edge("node_value", "parent_value")
        expect(subject.add_edge("node_value", "parent_value")).to be(false)
      end
    end
  end
  
  describe "#include?" do
    context "when value exists in the graph" do
      it "must return true" do
        subject.add_node("node_value")
        expect(subject.include?("node_value")).to be(true)
      end
    end

    context "when value does not exists in the graph" do
      it "must return false" do
        expect(subject.include?("node_value")).to be(false)
      end
    end
  end
  
  describe "#[]" do
    context "when node value exists in the graph" do
      it "returns set" do
        subject.add_edge("node_value")
        expect(subject["node_value"]).to eq(Set.new([nil]))
      end
    end

    context "when node value does not exists in the graph" do
      it "must return nil" do
        expect(subject["node_value"]).to be(nil) 
      end
    end
  end
end