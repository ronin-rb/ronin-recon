require 'spec_helper'
require 'ronin/recon/builtin/dns/lookup'

describe Ronin::Recon::DNS::Lookup do
  describe "#process" do
    context "when there are IP addresses for the host" do
      let(:host) { Ronin::Recon::Values::Host.new('www.example.com') }
      let(:ip)   { Ronin::Recon::Values::IP.new('93.184.216.34', host: 'www.example.com') }

      it "must yield them" do
        yielded_values = []

        Async do
          subject.process(host) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to eq([ip])
      end
    end

    context "when there is no IP address for the host" do
      let(:host) { Ronin::Recon::Values::Host.new('www.example.com') }

      it "must not yield anything" do
        expect { |b|
          Async do
            subject.process(host,&b)
          end
        }.not_to yield_control
      end
    end
  end
end
