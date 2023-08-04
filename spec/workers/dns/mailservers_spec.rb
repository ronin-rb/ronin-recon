require 'spec_helper'
require 'ronin/recon/builtin/dns/mailservers'

describe Ronin::Recon::DNS::Mailservers do
  describe "#process" do
    context "when there are mailservers for the domain" do
      let(:domain)       { Ronin::Recon::Values::Domain.new('example.com') }
      let(:mailserver)   { Ronin::Recon::Values::Mailserver.new('example.com') }

      it "must yield them" do
        yielded_values = []

        Async do
          subject.process(domain) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to eq([mailserver])
      end
    end

    context "when there is no mailserver for the domain" do
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
