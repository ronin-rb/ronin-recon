require 'spec_helper'
require 'ronin/recon/builtin/web/email_addresses'
require 'ronin/recon/values/url'

describe Ronin::Recon::Web::EmailAddresses do
  describe "#process" do
    context "when URL #body exists" do
      context "and email is present" do
        let(:email_address1) { 'example1@example.com' }
        let(:email_address2) { 'example2@example.com' }
        let(:body) do
          <<~HTML
            <html>
              <body>
                <p>#{email_address1}</p>
                <p>#{email_address2}</p>
              </body>
            </html>
          HTML
        end
        let(:url) { Ronin::Recon::Values::URL.new("example.com", body: body) }
        let(:expected_emails) do
          [
            Ronin::Recon::Values::EmailAddress.new(email_address1),
            Ronin::Recon::Values::EmailAddress.new(email_address2)
          ]
        end

        it "must return array of EmailAddresses" do
          yielded_values = []

          subject.process(url) do |value|
            yielded_values << value
          end

          expect(yielded_values).to eq(expected_emails)
        end

        context "but the URL #body is binary data" do
          let(:body) { super().encode(Encoding::ASCII_8BIT) }

          it "must convert the #body into a UTF-8 String" do
            yielded_values = []

            subject.process(url) do |value|
              yielded_values << value
            end

            expect(yielded_values).to eq(expected_emails)
          end

          context "and it contains invalid UTF-8 byte-sequences" do
            let(:body) do
              "\xfe\xff#{email_address1}\xfe\xff#{email_address2}\xfe\xff".b
            end

            it "must ignore any invalid UTF-8 byte sequences and only yield email address values" do
              yielded_values = []

              subject.process(url) do |value|
                yielded_values << value
              end

              expect(yielded_values).to eq(expected_emails)
            end
          end
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
