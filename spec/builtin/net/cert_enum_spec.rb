require 'spec_helper'
require 'ronin/recon/builtin/net/cert_enum'

describe Ronin::Recon::Net::CertEnum do
  describe "#process" do
    context "when there are Values in cert" do
      let(:fixtures_dir)  { File.expand_path(File.join(__dir__,'..','..','values','fixtures')) }
      let(:cert_path)     { File.join(fixtures_dir,'example.crt') }
      let(:cert)          { Ronin::Support::Crypto::Cert.load_file(cert_path) }
      let(:expected) do
        %w[
          www.example.org
          www.example.org
          www.example.com
          www.example.edu
          www.example.net
          example.org
          example.com
          example.edu
          example.net
        ]
      end

      it "must yield found Values" do
        yielded_values = []

        subject.process(cert) do |value|
          yielded_values << value
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values.map(&:name)).to match_array(expected)
      end
    end

    context "when there is no Value in cert" do
      let(:cert) { nil }

      it "must not yield anything" do
        expect { |b|
          subject.process(cert,&b)
        }.to_not yield_control
      end
    end
  end
end
