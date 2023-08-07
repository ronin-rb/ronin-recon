require 'spec_helper'
require 'ronin/recon/builtin/dns/mailservers'

describe Ronin::Recon::DNS::Mailservers do
  describe "#process" do
    context "when there are mailservers for the domain" do
      let(:domain)       { Ronin::Recon::Values::Domain.new('gmail.com') }
      let(:mailservers) do
        %w[
          alt1.gmail-smtp-in.l.google.com
          alt2.gmail-smtp-in.l.google.com
          alt3.gmail-smtp-in.l.google.com
          gmail-smtp-in.l.google.com
          alt4.gmail-smtp-in.l.google.com
        ]
      end

      it "must yield Mailsever values" do
        yielded_values = []

        Async do
          subject.process(domain) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Mailserver))
        expect(yielded_values.map(&:name).map(&:to_s)).to match_array(mailservers)
      end
    end

    context "when there is no mailserver for the domain" do
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
