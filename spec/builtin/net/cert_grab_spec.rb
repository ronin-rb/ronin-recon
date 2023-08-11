require 'spec_helper'
require 'ronin/recon/builtin/net/cert_grab'

describe Ronin::Recon::Net::CertGrab do
  describe "#process" do
    context "when there are certificates in the open port" do
      let(:port)  { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 443, service: 'http', ssl: true) }

      it "must yield Cert" do
        yielded_values = []

        Async do
          subject.process(port) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Cert))
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
