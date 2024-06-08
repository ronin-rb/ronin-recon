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

  describe "#===" do
    context "when given an Host object" do
      context "and the other Host object has a #name that ends with the Domain's #name" do
        let(:other) { described_class.new(name) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other Host object has a #name that ends in a different domain name" do
        let(:other) { described_class.new("www.other.com") }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given an IP object" do
      context "and the other IP object has a #host that matches the Domain's #name" do
        let(:other) do
          Ronin::Recon::Values::IP.new('93.184.216.34', host: name)
        end

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other IP object has a #name that ends in a different domain name" do
        let(:other) do
          Ronin::Recon::Values::IP.new('127.0.0.1', host: "localhost")
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given an Website object" do
      context "and the other Website object has a #host that matches the Domain's #name" do
        let(:other) do
          Ronin::Recon::Values::Website.http(name)
        end

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other Website object has a #name that ends in a different domain name" do
        let(:other) do
          Ronin::Recon::Values::Website.http("localhost")
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given an URL object" do
      context "and the other URL object has a #host that matches the Domain's #name" do
        let(:other) do
          Ronin::Recon::Values::URL.new(
            URI.parse("http://#{name}/"), status:  200,
                                          headers: {
                                            "content-type" => ["text/html"]
                                          },
                                          body: "html"
          )
        end

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other URL object has a #name that ends in a different domain name" do
        let(:other) do
          Ronin::Recon::Values::URL.new(
            URI.parse("http://localhost/"), status:  200,
                                            headers: {
                                              "content-type" => ["text/html"]
                                            },
                                            body: "html"
          )
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given a non-Host object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject === other).to be(false)
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
