require 'spec_helper'
require 'ronin/recon/value/parser'

describe Ronin::Recon::Value do
  describe ".parse" do
    subject { described_class }

    context "when given an IP CIDR range string" do
      let(:string) { '1.2.3.4/24' }

      it "must return a Values::IPRange object created with the string" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::IPRange)
        expect(value.range).to be_kind_of(Ronin::Support::Network::IPRange)
        expect(value.range.string).to eq(string)
      end
    end

    context "when given an IP glob range string" do
      let(:string) { '1.2-10.2,3,4.*' }

      it "must return a Values::IPRange object created with the string" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::IPRange)
        expect(value.range).to be_kind_of(Ronin::Support::Network::IPRange)
        expect(value.range.string).to eq(string)
      end
    end

    context "when given an IP string" do
      let(:string) { '1.2.3.4' }

      it "must return a Values::IP object created with the string" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::IP)
        expect(value.address).to eq(string)
      end
    end

    context "when given website base URL" do
      let(:host)   { 'example.com' }
      let(:string) { "#{scheme}://#{host}" }

      context "and the string starts with 'http://'" do
        let(:scheme) { :http }

        it "must return a Values::Website object with a :http scheme, host, and port of 443" do
          value = subject.parse(string)

          expect(value).to be_kind_of(Ronin::Recon::Values::Website)
          expect(value.scheme).to be(scheme)
          expect(value.host).to eq(host)
          expect(value.port).to eq(80)
        end

        context "and the base URL contains a custom port" do
          let(:port)   { 8080 }
          let(:string) { "#{scheme}://#{host}:#{port}" }

          it "must set the port" do
            value = subject.parse(string)

            expect(value).to be_kind_of(Ronin::Recon::Values::Website)
            expect(value.scheme).to be(scheme)
            expect(value.host).to eq(host)
            expect(value.port).to eq(port)
          end
        end
      end

      context "and the string starts with 'https://'" do
        let(:scheme) { :https }

        it "must return a Values::Website object with a :https scheme, host, and port of 443" do
          value = subject.parse(string)

          expect(value).to be_kind_of(Ronin::Recon::Values::Website)
          expect(value.scheme).to be(scheme)
          expect(value.host).to eq(host)
          expect(value.port).to eq(443)
        end

        context "and the base URL contains a custom port" do
          let(:port)   { 8080 }
          let(:string) { "#{scheme}://#{host}:#{port}" }

          it "must set the port" do
            value = subject.parse(string)

            expect(value).to be_kind_of(Ronin::Recon::Values::Website)
            expect(value.scheme).to be(scheme)
            expect(value.host).to eq(host)
            expect(value.port).to eq(port)
          end
        end
      end
    end

    context "when given a wildcard hostname string" do
      let(:string) { '*.example.com' }

      it "must return a Values::Wildcard object created with the string" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::Wildcard)
        expect(value.template).to eq(string)
      end
    end

    context "when given a domain string" do
      let(:string) { 'example.com' }

      it "must return a Values::Domain object created with the string" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::Domain)
        expect(value.name).to eq(string)
      end
    end

    context "when given a hostname string" do
      let(:string) { 'www.example.com' }

      it "must return a Values::Host object created with the string" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::Host)
        expect(value.name).to eq(string)
      end
    end

    context "when given an unknown string" do
      let(:string) { 'foo' }

      it do
        expect {
          subject.parse(string)
        }.to raise_error(Ronin::Recon::UnknownValue,"unrecognized recon value: #{string.inspect}")
      end
    end
  end
end
