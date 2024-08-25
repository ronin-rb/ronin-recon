require 'spec_helper'
require 'ronin/recon/builtin/api/zoom_eye'

require 'webmock/rspec'

describe Ronin::Recon::API::ZoomEye do
  let(:api_key) { 'my-test-api-key' }

  subject { described_class.new(params: { api_key: api_key }) }

  describe "#initialize" do
    it "must initialize #client for 'https://api.zoomeye.hk'" do
      expect(subject.client).to be_kind_of(Async::HTTP::Client)
    end
  end

  describe "#process" do
    context "for domain with subdomains and ip_addresses" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:response_json) do
        "{\"status\":200,\"total\":183386,\"list\":[{\"name\":\"api.example.com\",\"ip\":[\"1.1.1.1\"]},{\"name\":\"test.example.com\",\"ip\":[\"2.2.2.2\"]}]}"
      end
      let(:expected) do
        [
          Ronin::Recon::Values::Domain.new('api.example.com'),
          Ronin::Recon::Values::Domain.new('test.example.com'),
          Ronin::Recon::Values::IP.new('1.1.1.1'),
          Ronin::Recon::Values::IP.new('2.2.2.2')
        ]
      end

      before do
        stub_request(:get, "https://api.zoomeye.hk/domain/search?q=#{domain}&type=1")
          .with(headers: { "API-KEY" => 'my-test-api-key' })
          .to_return(status: 200, body: response_json)
      end

      it "must yield Values::Domain and Values::IP for each subdomain" do
        yielded_values = []

        Async do
          subject.process(domain) do |subdomain|
            yielded_values << subdomain
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to match_array(expected)
      end
    end

    context "for domain with no subdomains" do
      let(:domain) { Ronin::Recon::Values::Domain.new("invalid.com") }
      let(:response_json) do
        "{\"status\":200,\"total\":183386,\"list\":[]}"
      end

      before do
        stub_request(:get, "https://api.zoomeye.hk/domain/search?q=#{domain}&type=1")
          .with(headers: { "API-KEY" => 'my-test-api-key' })
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
