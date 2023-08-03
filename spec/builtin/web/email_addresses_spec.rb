require 'spec_helper'
require 'ronin/recon/builtin/web/email_addresses'
require 'ronin/recon/values/url'

describe Ronin::Recon::Web::EmailAddresses do
  describe "#process" do
    let(:emails) { [] }

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
        let(:valid_emails) do
          [
            Ronin::Recon::Values::EmailAddress.new("example@example.com"),
            Ronin::Recon::Values::EmailAddress.new("example1@example.com")
          ]
        end

        it "must return array of EmailAddresses" do
          subject.process(url) { |e| emails << e }

          expect(emails).to eq(valid_emails)
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
          subject.process(url) { |e| emails << e }

          expect(emails).to eq([])
        end
      end
    end

    context "when url body is nil" do
      let(:url) { Ronin::Recon::Values::URL.new("example.com") }

      it "must return nil" do
        expect(subject.process(url)).to be(nil)
      end
    end
  end
end
