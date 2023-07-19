require 'spec_helper'
require 'ronin/recon/values/email_address'

describe Ronin::Recon::Values::EmailAddress do
  let(:address) { 'john.smith@example.com' }

  subject { described_class.new(address) }

  describe "#initialize" do
    it "must set #address" do
      expect(subject.address).to eq(address)
    end
  end

  describe "#eql?" do
    context "when given an email address object" do
      context "and the other email address object has the same #address" do
        let(:other) { described_class.new(address) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other email address object has a different #address" do
        let(:other) { described_class.new('127.0.0.1') }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-email address object" do
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
      expect(subject.as_json).to eq({type: :email_address, address: address})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :email_address" do
      expect(subject.value_type).to be(:email_address)
    end
  end
end
