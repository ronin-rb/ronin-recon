require 'spec_helper'
require 'ronin/recon/builtin/web/email_addresses'
require 'ronin/recon/values/url'

describe Ronin::Recon::Web::EmailAddresses do
  describe "#process" do
    context "when URL #body exists" do
      context "and email is present" do
        let(:body) do
          <<~HTML
            <html>
              <body>
                <p>example@example.com</p>
                <p>example1@example.com</p>
              </body>
            </html>
          HTML
        end
        let(:url) { Ronin::Recon::Values::URL.new("example.com", body: body) }
        let(:expected_emails) do
          [
            Ronin::Recon::Values::EmailAddress.new("example@example.com"),
            Ronin::Recon::Values::EmailAddress.new("example1@example.com")
          ]
        end

        it "must return array of EmailAddresses" do
          yielded_values = []

          subject.process(url) do |value|
            yielded_values << value
          end

          expect(yielded_values).to eq(expected_emails)
        end
      end

      context "and email is not present" do
        let(:body) do
          <<~HTML
            <html>
              <body>
                <p>without email</p>
              </body>
            </html>
          HTML
        end
        let(:url) { Ronin::Recon::Values::URL.new("example.com", body: body) }

        it "must return empty array" do
          yielded_values = []

          subject.process(url) do |value|
            yielded_values << value
          end

          expect(yielded_values).to be_empty
        end
      end
    end

    context "when url body is nil" do
      let(:url) { Ronin::Recon::Values::URL.new("example.com") }

      it "must return nil" do
        expect { |b|
          subject.process(url,&b)
        }.to_not yield_control
      end
    end
  end
end
