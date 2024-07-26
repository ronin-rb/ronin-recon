require 'spec_helper'
require 'ronin/recon/builtin/ssl/cert_grab'

describe Ronin::Recon::SSL::CertGrab do
  describe "#process", :network do
    context "when there are certificates in the open port" do
      let(:port)          { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 443, service: 'http', ssl: true) }
      let(:fixtures_dir)  { File.join(__dir__,'..','..','fixtures','certs') }
      let(:cert_path)     { File.join(fixtures_dir,'example.crt') }
      let(:cert)          { Ronin::Support::Crypto::Cert.load_file(cert_path) }

      it "must yield Cert" do
        yielded_values = []

        Async do
          subject.process(port) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values.size).to eq(1)
        expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::Cert)
        expect(yielded_values[0].cert).to eq(cert)
      end
    end

    context "when there is no certificate in the open port" do
      let(:port) { Ronin::Recon::Values::OpenPort.new("192.168.0.1", 80) }

      it "must not yield anything" do
        expect { |b|
          Async do
            subject.process(port,&b)
          end
        }.to_not yield_control
      end
    end
  end
end
