require 'spec_helper'
require 'ronin/recon/scope'
require 'ronin/recon/values/url'
require 'ronin/recon/values/website'

describe Ronin::Recon::Scope do
  subject { described_class.new(values) }

  describe "#initialize" do
    context "for supported values" do
      let(:values) do
        [
          Ronin::Recon::Values::IP.new('1.2.3.4'),
          Ronin::Recon::Values::IPRange.new('1.2.3.4/24'),
          Ronin::Recon::Values::Domain.new('example.com'),
          Ronin::Recon::Values::Host.new('www.example.com'),
          Ronin::Recon::Values::Wildcard.new('*.example.com')
        ]
      end

      it "must initialize #values" do
        expect(subject.values).to eq(values)
      end
    end

    context "for not supported values" do
      let(:values) { [Ronin::Recon::Values::Website.parse('https://example.com')] }

      it "must raise NotImplementedError" do
        expect {
          subject
        }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#include?" do
    context "for value found in the scope" do
      let(:ip)     { Ronin::Recon::Values::IP.new('1.2.3.4') }
      let(:host)   { Ronin::Recon::Values::Host.new('www.example.com') }
      let(:values) { [ip, host] }

      it "must return true" do
        expect(subject.include?(ip)).to eq(true)
        expect(subject.include?(host)).to eq(true)
      end
    end

    context "for value not found in the scope" do
      let(:values) do
        [
          Ronin::Recon::Values::IPRange.new('12.22.33.44/24'),
          Ronin::Recon::Values::Wildcard.new('*.eexample.com')
        ]
      end

      let(:ip)   { Ronin::Recon::Values::IP.new('1.2.3.4') }
      let(:host) { Ronin::Recon::Values::Host.new('www.example.com') }

      it "must return false" do
        expect(subject.include?(ip)).to eq(false)
        expect(subject.include?(host)).to eq(false)
      end
    end

    context "for value other than Host/Domain/IP/IPRange/Wildcard" do
      let(:values) do
        [
          Ronin::Recon::Values::IPRange.new('12.22.33.44/24'),
          Ronin::Recon::Values::Wildcard.new('*.eexample.com')
        ]
      end

      let(:url)     { 'https://www.example.com/index.html' }
      let(:unknown) { Ronin::Recon::Values::URL.new(URI.parse(url)) }

      it "must return true" do
        expect(subject.include?(unknown)).to eq(true)
      end
    end

    context "for ignored values" do
      subject { described_class.new(values, ignore: [ignored_value]) }

      let(:values) do
        [
          Ronin::Recon::Values::IP.new('1.2.3.4'),
          Ronin::Recon::Values::Host.new('www.example.com')
        ]
      end

      let(:ignored_value) { Ronin::Recon::Values::Host.new('www.example.com') }

      it "must return false" do
        expect(subject.include?(values[0])).to eq(true)
        expect(subject.include?(ignored_value)).to eq(false)
      end
    end
  end
end
