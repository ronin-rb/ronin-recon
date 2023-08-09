require 'spec_helper'
require 'ronin/recon/builtin/web/spider'
require 'uri'

describe Ronin::Recon::Web::Spider do
  describe "#process" do
    context "when there are URL in the website" do
      let(:website) { Ronin::Recon::Values::Website.new(:https, "www.example.com", 443) }
      it "must yield URL" do
        yielded_values = []

        subject.process(website) do |value|
          yielded_values << value
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values.map(&:uri).first).to eq(website.to_uri)
        expect(yielded_values.map(&:status).first).to eq(200)
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::URL))
      end
    end

    context "when there are no URL in the website" do
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
