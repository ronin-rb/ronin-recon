require 'spec_helper'
require 'ronin/recon/builtin/dns/srv_enum'

describe Ronin::Recon::DNS::SRVEnum do
  describe "#process" do
    context "when there are hosts in the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new("gmail.com") }
      let(:hosts) do
        %w[
          imap.gmail.com
          smtp.gmail.com
          pop.gmail.com
          calendar.google.com
          calendar.google.com
        ]
      end

      it "must yield Host values" do
        yielded_values = []

        subject.process(domain) do |value|
          yielded_values << value
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Host))
        expect(yielded_values.map(&:name).reject(&:empty?)).to eq(hosts)
      end
    end

    context "when there is no host in the domain" do
      let(:domain) { Ronin::Recon::Values::Domain.new("example.invalid") }

      it "must not yield anything" do
        expect { |b|
          subject.process(domain,&b)
        }.to_not yield_control
      end
    end
  end
end
