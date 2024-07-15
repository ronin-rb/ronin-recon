require 'spec_helper'
require 'ronin/recon/scope'
require 'ronin/recon/values/url'

describe Ronin::Recon::Scope do
  let(:values) do
    [
      Ronin::Recon::Values::IP.new('1.2.3.4'),
      Ronin::Recon::Values::IPRange.new('1.2.3.4/24'),
      Ronin::Recon::Values::Domain.new('example.com'),
      Ronin::Recon::Values::Host.new('www.example.com'),
      Ronin::Recon::Values::Wildcard.new('*.example.com'),
      Ronin::Recon::Values::Website.parse('https://blog.example.com')
    ]
  end

  subject { described_class.new(values) }

  describe "#initialize" do
    context "for supported values" do
      it "must initialize #values" do
        expect(subject.values).to eq(values)
      end
    end

    context "for non-supported values" do
      let(:value) do
        Ronin::Recon::Values::URL.new('https://example.com/foo')
      end
      let(:values) { [value] }

      it do
        expect {
          described_class.new(values)
        }.to raise_error(NotImplementedError,"scope value type not supported: #{value.inspect}")
      end
    end

    context "when no ignore: keyword argument is given" do
      it "must initialize #ignore to []" do
        expect(subject.ignore).to eq([])
      end
    end

    context "when the ignore: keyword argument is given" do
      let(:ignore) do
        [
          Ronin::Recon::Values::Host.new('dev.example.com'),
          Ronin::Recon::Values::Host.new('staging.example.com')
        ]
      end

      subject { described_class.new(values, ignore: ignore) }

      it "must initialize #ignore" do
        expect(subject.ignore).to eq(ignore)
      end
    end
  end

  describe "#include?" do
    context "when given a value that exactly matches a value in the scope" do
      let(:ip)     { Ronin::Recon::Values::IP.new('1.2.3.4') }
      let(:host)   { Ronin::Recon::Values::Host.new('www.example.com') }
      let(:values) { [ip, host] }

      it "must return true" do
        expect(subject.include?(ip)).to be(true)
        expect(subject.include?(host)).to be(true)
      end
    end

    context "when given a value that fuzzy matches a value in the scope using #===" do
      let(:values) do
        [
          Ronin::Recon::Values::IPRange.new('12.22.33.44/24'),
          Ronin::Recon::Values::Wildcard.new('*.example.com')
        ]
      end

      let(:ip)   { Ronin::Recon::Values::IP.new('12.22.33.42') }
      let(:host) { Ronin::Recon::Values::Host.new('www.example.com') }
      let(:url) do
        Ronin::Recon::Values::URL.new('https://www.example.com/index.html')
      end

      it "must return true" do
        expect(subject.include?(ip)).to be(true)
        expect(subject.include?(host)).to be(true)
        expect(subject.include?(url)).to be(true)
      end
    end

    context "for value not found in the scope" do
      let(:values) do
        [
          Ronin::Recon::Values::IPRange.new('12.22.33.44/24'),
          Ronin::Recon::Values::Wildcard.new('*.example.com')
        ]
      end

      let(:ip)   { Ronin::Recon::Values::IP.new('1.2.3.4') }
      let(:host) { Ronin::Recon::Values::Host.new('www.other.com') }

      it "must return false" do
        expect(subject.include?(ip)).to be(false)
        expect(subject.include?(host)).to be(false)
      end
    end

    context "when initialized with ignore: values" do
      subject { described_class.new(values, ignore: ignore_values) }

      context "and the given value exactly matches one of the ignore values" do
        let(:ignored_value) do
          Ronin::Recon::Values::Host.new('staging.example.com')
        end
        let(:ignore_values) { [ignored_value] }

        it "must return false" do
          expect(subject.include?(ignored_value)).to be(false)
        end
      end

      context "and the given value fuzzy matches one of the ignore values using #===" do
        let(:ignore_values) do
          [
            Ronin::Recon::Values::IP.new('10.0.0.0/8'),
            Ronin::Recon::Values::Wildcard.new('*.dev.example.com')
          ]
        end

        let(:ignored_ip) do
          Ronin::Recon::Values::IP.new('10.1.1.1')
        end

        let(:ignored_host) do
          Ronin::Recon::Values::Host.new('testing.dev.example.com')
        end

        let(:ignored_url) do
          Ronin::Recon::Values::URL.new('https://testing.dev.example.com/index.html')
        end

        it "must return false" do
          expect(subject.include?(ignored_ip)).to be(false)
          expect(subject.include?(ignored_host)).to be(false)
          expect(subject.include?(ignored_url)).to be(false)
        end
      end
    end
  end
end
