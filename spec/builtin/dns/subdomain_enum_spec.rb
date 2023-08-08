require 'spec_helper'
require 'ronin/recon/builtin/dns/subdomain_enum'

describe Ronin::Recon::DNS::SubdomainEnum do
  context "#process" do
    context "when there is a host for the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new('example.com') }
      let(:hosts)  { ["www.example.com"] }
      
      it "must yield Host" do
        yielded_values = []

        subject.process(domain) do |value|
          yielded_values << value
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Host))
        expect(yielded_values.map(&:name).map(&:to_s)).to eq(hosts)
      end
    end
      
    context "when there is no host for the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new('localhost') }

      it "must not yield anything" do
        expect { |b|
          subject.process(domain,&b)
        }.not_to yield_control
      end
    end
  end
end