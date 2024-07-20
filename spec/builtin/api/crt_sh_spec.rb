require 'spec_helper'
require 'ronin/recon/builtin/api/crt_sh'

describe Ronin::Recon::API::CrtSh do
  it "must set concurrency to 1" do
    expect(described_class.concurrency).to eq(1)
  end

  describe "#initialize" do
    it "must initialize #client for 'https://crt.sh'" do
      expect(subject.client).to be_kind_of(Async::HTTP::Client)
      # BUG: https://github.com/bblimke/webmock/issues/1060
      # expect(subject.client.endpoint).to be_kind_of(Async::HTTP::Endpoint)
      # expect(subject.client.endpoint.scheme).to eq('https')
      # expect(subject.client.endpoint.hostname).to eq('crt.sh')
      # expect(subject.client.endpoint.port).to eq(443)
    end
  end

  describe "#process", :network do
    context "for domain with certificates" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:expected) do
        %w[
          www.example.org
          example.com
        ]
      end

      it "must yield Values::Host for each certificate" do
        yielded_values = []

        Async do
          subject.process(domain) do |host|
            yielded_values << host
          end
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

        Async do
          subject.process(domain) do |host|
            yielded_values << host
          end
        end

        expect(yielded_values).to be_empty
      end
    end
  end
end
