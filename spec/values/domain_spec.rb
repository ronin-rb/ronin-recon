require 'spec_helper'
require 'ronin/recon/values/domain'

describe Ronin::Recon::Values::Domain do
  let(:name) { 'example.com' }

  subject { described_class.new(name) }

  describe "#===" do
    context "when given an Domain object" do
      context "and the other Domain object has the same #name" do
        let(:other) { described_class.new(name) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other Domain object has a different #name" do
        let(:other) { described_class.new('other.com') }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given an Host object" do
      context "and the other Host object has a #name that ends with the Domain's #name" do
        let(:other) { Ronin::Recon::Values::Host.new("www.#{name}") }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other Host object has a #name that ends in a different domain name" do
        let(:other) { Ronin::Recon::Values::Host.new("www.other.com") }

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

      context "and the other IP object has a #host that ends with the Domain's #name" do
        let(:other) do
          Ronin::Recon::Values::IP.new('93.184.216.34', host: "www.#{name}")
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

      context "and the other Website object has a #host that ends with the Domain's #name" do
        let(:other) do
          Ronin::Recon::Values::Website.http("www.#{name}")
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

      context "and the other URL object has a #host that ends with the Domain's #name" do
        let(:other) do
          Ronin::Recon::Values::URL.new(
            URI.parse("http://www.#{name}/"), status:  200,
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

    context "when given an EmailAddress object" do
      context "and the other EmailAddress ends with the domain name" do
        let(:other) do
          Ronin::Recon::Values::EmailAddress.new("john.smith@#{name}")
        end

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "and the other EmailAddress's host name is a sub-domain of the domain name" do
        let(:other) do
          Ronin::Recon::Values::EmailAddress.new("john.smith@subdomain.#{name}")
        end

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other EmailAddress has a different domain name" do
        let(:other) do
          Ronin::Recon::Values::EmailAddress.new("john.smith@other.com")
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

  describe "#as_json" do
    it "must return a Hash containing the type: and name: attributes" do
      expect(subject.as_json).to eq({type: :domain, name: name})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :domain " do
      expect(subject.value_type).to be(:domain)
    end
  end
end
