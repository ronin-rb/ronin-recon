require 'spec_helper'
require 'ronin/recon/builtin/api/built_with'
require 'webmock/rspec'

describe Ronin::Recon::API::BuiltWith do
  let(:api_key) { 'my-test-api-key' }

  subject { described_class.new(params: { api_key: api_key }) }

  it "must set concurrency to 1" do
    expect(described_class.concurrency).to eq(1)
  end

  describe "#process" do
    context "for domain with subdomains" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:response_json) do
        "{\"Results\":[{\"Result\":{\"Paths\":[{\"Domain\":\"example.com\",\"SubDomain\":\"api\"},{\"Domain\":\"example.com\",\"SubDomain\":\"test\"}]}}]}"
      end
      let(:expected) do
        %w[
          api.example.com
          test.example.com
        ]
      end

      before do
        stub_request(:get, "https://api.builtwith.com/v21/api.json?KEY=#{api_key}&LOOKUP=#{domain}")
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
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Domain))
        expect(yielded_values.map(&:name)).to eq(expected)
      end
    end

    context "for email addresses found on the lookup website" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
      let(:response_json) do
        "{\"Results\":[{\"Meta\":{\"Emails\":[\"email@example.com\",\"test@example.com\"]}}]}"
      end
      let(:expected) do
        %w[
          email@example.com
          test@example.com
        ]
      end

      before do
        stub_request(:get, "https://api.builtwith.com/v21/api.json?KEY=#{api_key}&LOOKUP=#{domain}")
          .to_return(status: 200, body: response_json)
      end

      it "must yield Values::EmailAddress for each email address" do
        yielded_values = []

        Async do
          subject.process(domain) do |email|
            yielded_values << email
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::EmailAddress))
        expect(yielded_values.map(&:address)).to eq(expected)
      end
    end
  end
end
