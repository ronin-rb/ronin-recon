require 'spec_helper'
require 'ronin/recon/values/ip'

describe Ronin::Recon::Values::IP do
  let(:address) { '93.184.216.34' }
  let(:host)    { 'example.com' }

  subject { described_class.new(address) }

  describe "#initialize" do
    it "must set #address" do
      expect(subject.address).to eq(address)
    end

    context "when initialized with the host: keyword argument" do
      subject { described_class.new(address, host: host) }

      it "must also set #host" do
        expect(subject.host).to eq(host)
      end
    end
  end

  describe "#eql?" do
    context "when given an IP object" do
      context "and the other IP object has the same #address" do
        let(:other) { described_class.new(address) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other IP object has a different #address" do
        let(:other) { described_class.new('127.0.0.1') }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-IP object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #address" do
      expect(subject.hash).to eq([described_class, address].hash)
    end
  end

  describe "#to_s" do
    it "must return the #address" do
      expect(subject.to_s).to eq(address)
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and address: attributes" do
      expect(subject.as_json).to eq({type: :ip, address: address})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :ip" do
      expect(subject.value_type).to be(:ip)
    end
  end
end
