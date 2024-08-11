require 'spec_helper'
require 'ronin/recon/builtin/api/security_trails'

require 'webmock/rspec'

describe Ronin::Recon::API::SecurityTrails do
  subject do
    described_class.new(params: { api_key: 'my-test-api-key'})
  end

  it "must set concurrency to 1" do
    expect(described_class.concurrency).to eq(1)
  end

  describe "#initialize" do
    it "must initialize #client for 'https://api.securitytrails.com'" do
      expect(subject.client).to be_kind_of(Async::HTTP::Client)
      # BUG: https://github.com/bblimke/webmock/issues/1060
      # expect(subject.client.endpoint).to be_kind_of(Async::HTTP::Endpoint)
      # expect(subject.client.endpoint.scheme).to eq('https')
      # expect(subject.client.endpoint.hostname).to eq('api.securitytrails.com')
      # expect(subject.client.endpoint.port).to eq(443)
    end
  end

  describe "#process" do
    context "for domain with subdomains" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:response_json) do
        "{\"endpoint\":\"/v1/domain/example.com/subdomains\",\"meta\":{\"limit_reached\":true},\"subdomain_count\":3,\"subdomains\":[\"api\",\"test\",\"proxy\"]}"
      end
      let(:expected) do
        %w[
          api.example.com
          test.example.com
          proxy.example.com
        ]
      end

      before do
        stub_request(:get, "https://api.securitytrails.com/v1/domain/#{domain.name}/subdomains?children_only=false&include_inactive=false")
          .with(headers: {APIKEY: 'my-test-api-key'})
          .to_return(status: 200, body: response_json)
      end

      it "must yield Values::Domain for each subdomain" do
        yielded_values = []

        Async do
          subject.process(domain) do |subdomain|
            yielded_values << subdomain
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Host))
        expect(yielded_values.map(&:name)).to eq(expected)
      end
    end

    context "for domain with no subdomains" do
      let(:domain) { Ronin::Recon::Values::Domain.new("invalid.com") }
      let(:response_json) do
        "{\"endpoint\":\"/v1/domain/invalid.com/subdomains\",\"count\":null,\"subdomains\":[]}"
      end

      before do
        stub_request(:get, "https://api.securitytrails.com/v1/domain/#{domain.name}/subdomains?children_only=false&include_inactive=false")
          .with(headers: {APIKEY: 'my-test-api-key'})
          .to_return(status: 200, body: response_json)
      end

      it "must not yield anything" do
        yielded_values = []

        Async do
          subject.process(domain) do |subdomain|
            yielded_values << subdomain
          end
        end

        expect(yielded_values).to be_empty
      end
    end
  end
end
