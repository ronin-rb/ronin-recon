require 'spec_helper'
require 'ronin/recon/builtin/dns/nameservers'

describe Ronin::Recon::DNS::Nameservers do
  describe "#process", :network do
    context "when there are nameservers for the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new('example.com') }
      let(:nameservers) do
        %w[
          a.iana-servers.net
          b.iana-servers.net
        ]
      end

      it "must yield Nameserver values" do
        yielded_values = []

        Async do
          subject.process(domain) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Nameserver))
        expect(yielded_values.map(&:name).map(&:to_s)).to match_array(nameservers)
      end
    end

    context "when there is no nameserver for the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new('localhost') }

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
