require 'spec_helper'
require 'ronin/recon/builtin/api/crt_sh'

require 'webmock/rspec'

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

  describe "#process" do
    let(:domain) { Ronin::Recon::Values::Domain.new("example.com") }
    let(:json) do
      '[{"issuer_ca_id":185752,"issuer_name":"C=US, O=DigiCert Inc, CN=DigiCert Global G2 TLS RSA SHA256 2020 CA1","common_name":"www.example.org","name_value":"example.com\nwww.example.com","id":12337892544,"entry_timestamp":"2024-03-10T20:13:50.549","not_before":"2024-01-30T00:00:00","not_after":"2025-03-01T23:59:59","serial_number":"075bcef30689c8addf13e51af4afe187","result_count":2},{"issuer_ca_id":185752,"issuer_name":"C=US, O=DigiCert Inc, CN=DigiCert Global G2 TLS RSA SHA256 2020 CA1","common_name":"www.example.org","name_value":"example.com\nwww.example.com","id":11920382870,"entry_timestamp":"2024-01-30T19:22:50.288","not_before":"2024-01-30T00:00:00","not_after":"2025-03-01T23:59:59","serial_number":"075bcef30689c8addf13e51af4afe187","result_count":2},{"issuer_ca_id":-1,"issuer_name":"Issuer Not Found","common_name":"example.com","name_value":"example.com","id":8506962125,"entry_timestamp":null,"not_before":"2023-01-27T01:21:18","not_after":"2033-01-24T01:21:18","serial_number":"1ac1e693c87d36563a92ca145c87bbc26fd49f4c","result_count":1}]'
    end

    before do
      stub_request(:get, "https://crt.sh/?dNSName=#{domain.name}&exclude=expired&output=json").to_return(status: 200, body: json)
    end

    it "must request query the crt.sh API and yield Host values for each unique host name" do
      yielded_values = []

      Async do
        subject.process(domain) do |value|
          yielded_values << value
        end
      end

      expect(yielded_values).to eq([
        Ronin::Recon::Values::Host.new('www.example.org'),
        Ronin::Recon::Values::Host.new('example.com')
      ])
    end
  end

  describe "#process", :network do
    before(:all) { WebMock.allow_net_connect! }

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
