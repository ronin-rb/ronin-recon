require 'spec_helper'
require 'ronin/recon/builtin/api/hunter_io'

require 'webmock/rspec'

describe Ronin::Recon::API::HunterIO do
  let(:api_key) { 'my-test-api-key' }

  subject { described_class.new(params: { api_key: api_key }) }

  describe "#initialize" do
    it "must initialize #client for 'https://api.hunter.io'" do
      expect(subject.client).to be_kind_of(Async::HTTP::Client)
    end
  end

  describe "#process" do
    context "for domain with corresponding email addresses" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:response_json) do
        "{\"data\":{\"emails\":[{\"value\":\"foo@example.com\"},{\"value\":\"bar@example.com\"}]}}"
      end
      let(:expected) do
        %w[
          foo@example.com
          bar@example.com
        ]
      end

      before do
        stub_request(:get, "https://api.hunter.io/v2/domain-search?domain=#{domain}&api_key=#{api_key}")
          .to_return(status: 200, body: response_json)
      end

      it "must yield Values::EmailAddress for each subdomain" do
        yielded_values = []

        Async do
          subject.process(domain) do |subdomain|
            yielded_values << subdomain
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::EmailAddress))
        expect(yielded_values.map(&:address)).to eq(expected)
      end
    end

    context "for domain with no email addresses" do
      let(:domain) { Ronin::Recon::Values::Domain.new("invalid.com") }
      let(:response_json) do
        "{\"data\":{\"emails\":[]}}"
      end

      before do
        stub_request(:get, "https://api.hunter.io/v2/domain-search?domain=#{domain}&api_key=#{api_key}")
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
