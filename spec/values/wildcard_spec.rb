require 'spec_helper'
require 'ronin/recon/values/wildcard'

describe Ronin::Recon::Values::Wildcard do
  let(:template) { '*.example.com' }

  subject { described_class.new(template) }

  describe "#initialize" do
    it "must set #template" do
      expect(subject.template).to eq(template)
    end
  end

  describe "#===" do
    context "when given another Wildcard object" do
      context "and when the other Wildcard has the same #template" do
        let(:other) { described_class.new(template) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "and when the other Wildcard does not have the same #template" do
        let(:other_template) { '*.other.com' }
        let(:other)          { described_class.new(other_template) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given another Domain object" do
      context "and the Domain's #name matches the Wildcard template" do
        let(:template)   { 'example*.com' }
        let(:other_name) { 'example42.com' }
        let(:other)      { Ronin::Recon::Values::Domain.new(other_name) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the Domain's #name does not match the Wildcard template" do
        let(:template)   { 'example*.com' }
        let(:other_name) { 'other.com' }
        let(:other)      { Ronin::Recon::Values::Domain.new(other_name) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given another Host object" do
      context "and the Host's #name matches the Wildcard template" do
        let(:other_name) { 'www.example.com' }
        let(:other)      { Ronin::Recon::Values::Host.new(other_name) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the Host's #name does not match the Wildcard template" do
        let(:other_name) { 'www.other.com' }
        let(:other)      { Ronin::Recon::Values::Host.new(other_name) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given another URL object" do
      let(:other) do
        Ronin::Recon::Values::URL.new("https://#{other_host}/index.html")
      end

      context "and the URL's host name matches the Wildcard template" do
        let(:other_host) { 'www.example.com' }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the URL's host name does not match the Wildcard template" do
        let(:other_host) { 'www.other.com' }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given another kind of object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject === other).to be(false)
      end
    end
  end

  describe "#eql?" do
    context "when given a Wildcard object" do
      context "and the other Wildcard object has the same #template" do
        let(:other) { described_class.new(template) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other Wildcard object has a different #template" do
        let(:other_template) { '*.other.com' }
        let(:other)          { described_class.new(other_template) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-Wildcard object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #template" do
      expect(subject.hash).to eq([described_class, template].hash)
    end
  end

  describe "#to_s" do
    it "must return the #template" do
      expect(subject.to_s).to eq(template)
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and template: attributes" do
      expect(subject.as_json).to eq({type: :wildcard, template: template.to_s})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :wildcard" do
      expect(subject.value_type).to be(:wildcard)
    end
  end
end
