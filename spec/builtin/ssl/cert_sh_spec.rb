require 'spec_helper'
require 'ronin/recon/builtin/ssl/cert_sh'

describe Ronin::Recon::SSL::CertSh do
  describe "#process" do
    context "for domain with certificates" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:expected) do
        %w[
          www.example.org
          www.example.org
          example.com
        ]
      end
      it "must yield Values::Host for each certificate" do
        yielded_values = []

        subject.process(domain) do |host|
          yielded_values << host
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Host))
        expect(yielded_values.map(&:name)).to eq(expected)
      end
    end

    context "for domain with no certificates" do
      let(:domain) { Ronin::Recon::Values::Domain.new("invalid.com") }

      it "must not yield anything" do
        yielded_values = []

        subject.process(domain) do |host|
          yielded_values << host
        end

        expect(yielded_values).to be_empty
      end
    end
  end
end
