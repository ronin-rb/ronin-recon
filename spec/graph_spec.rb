require 'spec_helper'
require 'ronin/recon/graph'
require 'ronin/recon/values/ip'

describe Ronin::Recon::Graph do
  subject { described_class.new }
  let(:value1) { Ronin::Recon::Values::IP.new('192.168.0.1') }
  let(:value2) { Ronin::Recon::Values::IP.new('192.168.1.1') }

  describe "#initialize" do
    it "must initialize #nodes and #edges" do
      expect(subject.nodes).to eq(Set.new)
      expect(subject.edges).to eq({})
    end
  end

  describe "#add_node" do
    context "when value node was successfully added" do
      it "must return true" do
        expect(subject.add_node(value1)).to be(true)
      end

      it "must contain node" do
        subject.add_node(value1)

        expect(subject.nodes.size).to eq(1)
      end
    end

    context "when value node was already added" do
      it "must return false" do
        subject.add_node(value1)

        expect(subject.add_node(value1)).to be(false)
      end
    end
  end

  describe "#add_edge" do
    context "when node value was successfully added" do
      it "must return true" do
        expect(subject.add_edge(value1,value2)).to be(true)
      end
    end

    context "when node value was already added" do
      it "must return false" do
        subject.add_edge(value1,value2)

        expect(subject.add_edge(value1,value2)).to be(false)
      end
    end
  end

  describe "#include?" do
    context "when value exists in the graph" do
      it "must return true" do
        subject.add_node(value1)

        expect(subject.include?(value1)).to be(true)
      end
    end

    context "when value does not exists in the graph" do
      it "must return false" do
        expect(subject.include?(value1)).to be(false)
      end
    end
  end

  describe "#[]" do
    context "when node value exists in the graph" do
      context "and has no edges" do
        it "returns empty Set" do
          subject.add_node(value1)

          expect(subject[value1]).to be(nil)
        end
      end

      context "and has edges to other nodes" do
        it "returns no-empty Set" do
          subject.add_edge(value1,value2)

          expect(subject[value1]).to eq(Set.new([value2]))
        end
      end
    end

    context "when node value does not exists in the graph" do
      it "must return nil" do
        expect(subject[value1]).to be(nil)
      end
    end
  end
end
