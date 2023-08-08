require 'spec_helper'
require 'ronin/recon/builtin/web/spider'
require 'uri'

describe Ronin::Recon::Web::Spider do
  describe "#process", :network do
    context "when there are URLs in the website" do
      let(:website) { Ronin::Recon::Values::Website.new(:https, "www.google.com", 443) }
      let(:expected_uris) do
        [
          "https://www.google.com/",
          "https://www.google.com/preferences?hl=pl",
          "https://www.google.com/advanced_search?hl=pl&authuser=0",
          "https://www.google.com/intl/pl/policies/privacy/",
          "https://www.google.com/intl/pl/policies/terms/",
          "https://www.google.com/xjs/_/ss/k=xjs.hp.Rf6tYsQEqH4.L.X.O/am=AQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAEMgAAAAAAEAAAAIgAAIAg/d=1/ed=1/rs=ACT90oEwkAntX8xwkxuouRQvNEvlrRcUvQ/m=sb_he,d"
        ]
      end

      it "must yield URL" do
        yielded_values = []

        subject.process(website) do |value|
          yielded_values << value
        end

        expect(yielded_values.size).to eq(6)
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::URL))
        expect(yielded_values.map(&:uri).map(&:to_s)).to match_array(expected_uris)
        expect(yielded_values.map(&:status)).to all(eq(200))
      end
    end

    context "when there are no URLs in the website" do
      let(:website) { Ronin::Recon::Values::Website.new(:https, "www.foo.invalid", 443) }

      it "must not yield anything" do
        expect { |b|
          Async do
            subject.process(website,&b)
          end
        }.not_to yield_control
      end
    end
  end
end
