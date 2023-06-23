require 'spec_helper'
require 'ronin/recon/values/host'

describe Ronin::Recon::Values::Host do
  let(:name) { 'www.example.com' }

  subject { described_class.new(name) }

  describe "#initialize" do
    it "must set #name" do
      expect(subject.name).to eq(name)
    end
  end

  describe "#eql?" do
    context "when given an Host object" do
      context "and the other Host object has the same #name" do
        let(:other) { described_class.new(name) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other Host object has a different #name" do
        let(:other) { described_class.new('other.example.com') }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-Host object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #name" do
      expect(subject.hash).to eq([described_class, name].hash)
    end
  end

  describe "#to_s" do
    it "must return the #name" do
      expect(subject.to_s).to eq(name)
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and name: attributes" do
      expect(subject.as_json).to eq({type: :host, name: name})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :host" do
      expect(subject.value_type).to be(:host)
    end
  end
end
