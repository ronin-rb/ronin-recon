require 'spec_helper'
require 'ronin/recon/values/url'

describe Ronin::Recon::Values::URL do
  let(:url) { 'https://www.example.com/index.html' }
  let(:uri) { URI.parse(url) }

  subject { described_class.new(url) }

  describe "#initialize" do
    context "when given a URI" do
      subject { described_class.new(uri) }

      it "must set #uri to the URI object" do
        expect(subject.uri).to eq(uri)
      end
    end

    context "when given a String" do
      subject { described_class.new(url) }

      it "must set #uri to the parsed version of the given URL" do
        expect(subject.uri).to eq(uri)
      end
    end
  end

  describe "#eql?" do
    context "when given an URL object" do
      context "and the other URL object has the same #uri" do
        let(:other) { described_class.new(url) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other URL object has a different #uri" do
        let(:other_uri) { URI.parse('https://other.com/index.html') }
        let(:other)     { described_class.new(other_uri) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-URL object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #name" do
      expect(subject.hash).to eq([described_class, uri].hash)
    end
  end

  describe "#to_s" do
    it "must return the String form of #uri" do
      expect(subject.to_s).to eq(url)
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and url: attributes" do
      expect(subject.as_json).to eq({type: :url, url: url})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :url" do
      expect(subject.value_type).to be(:url)
    end
  end
end
