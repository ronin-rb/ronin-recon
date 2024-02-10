require 'spec_helper'
require 'ronin/recon/values/ip_range'

describe Ronin::Recon::Values::IPRange do
  let(:range) { Ronin::Support::Network::IPRange.new('93.184.216.0/24') }

  subject { described_class.new(range) }

  describe "#initialize" do
    context "when the range is a Ronin::Support::Network::IPRange" do
      it "must set #range" do
        expect(subject.range).to be(range)
      end
    end

    context "when the range is a String" do
      let(:range) { '93.184.216.0/24' }

      subject { described_class.new(range) }

      it "must set #range to an Ronin::Support::Network::IPRange" do
        expect(subject.range).to be_kind_of(Ronin::Support::Network::IPRange)
        expect(subject.range.string).to eq(range)
      end
    end

    context "when the range is neither an IPAddr or String" do
      let(:range) { Object.new }

      it do
        expect {
          described_class.new(range)
        }.to raise_error(ArgumentError,"IP range must be either an IPAddr or String: #{range.inspect}")
      end
    end
  end

  describe "#include?" do
    context "when the given IP address is within the range" do
      let(:ip) { '93.184.216.42' }

      it "must return true" do
        expect(subject.include?(ip)).to be(true)
      end
    end

    context "when the given IP address is not in the range" do
      let(:ip) { '8.8.8.8' }

      it "must return false" do
        expect(subject.include?(ip)).to be(false)
      end
    end
  end

  describe "#===" do
    context "when given an IPRange object" do
      context "and the other's IP range is equal to the IP range" do
        let(:other) { described_class.new(range) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "and the other's IP range is a subset of the IP range" do
        let(:other_range) { '93.184.216.0/30' }
        let(:other)       { described_class.new(other_range) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other's IP range does not intersect with the IP range" do
        let(:other_range) { '10.0.0.0/24' }
        let(:other)       { described_class.new(other_range) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given an IP object" do
      context "and when the IP address is within the IP range" do
        let(:other_address) { '93.184.216.34' }
        let(:other)         { Ronin::Recon::Values::IP.new(other_address) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "and when the IP address is not within the IP range" do
        let(:other_address) { '8.8.8.8' }
        let(:other)         { Ronin::Recon::Values::IP.new(other_address) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given a non-IPRange or non-IP object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject === other).to be(false)
      end
    end
  end

  describe "#eql?" do
    context "when given an IP object" do
      context "and the other IP object has the same #range" do
        let(:other) { described_class.new(range) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other IP object has a different #range" do
        let(:other_range) { '10.0.0.0/24' }
        let(:other)       { described_class.new(other_range) }

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
    it "must return the #hash of an Array containing the class and the #range" do
      expect(subject.hash).to eq([described_class, range].hash)
    end
  end

  describe "#to_s" do
    it "must return the String version of #range" do
      expect(subject.to_s).to eq(range.to_s)
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and range: attributes" do
      expect(subject.as_json).to eq({type: :ip_range, range: range.to_s})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :ip_range" do
      expect(subject.value_type).to be(:ip_range)
    end
  end
end
