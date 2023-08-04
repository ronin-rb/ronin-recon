require 'spec_helper'
require 'ronin/recon/builtin/dns/nameservers'

describe Ronin::Recon::DNS::Nameservers do
  describe "#process" do
    context "when there are nameservers for the domain" do
      let(:domain)        { Ronin::Recon::Values::Domain.new('example.com') }
      let(:nameserver)    { Ronin::Recon::Values::Nameserver.new('a.iana-servers.net') }
      let(:nameserver2)   { Ronin::Recon::Values::Nameserver.new('b.iana-servers.net') }

      it "must yield them" do
        yielded_values = []

        Async do
          subject.process(domain) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to eq([nameserver, nameserver2])
      end
    end

    context "when there is no nameserver for the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new('e.com') }

      it "must not yield anything" do
        expect { |b|
          Async do
            subject.process(domain,&b)
          end
        }.not_to yield_control
      end
    end
  end
end
