require 'spec_helper'
require 'ronin/recon/values/url'

describe Ronin::Recon::Values::URL do
  let(:url) { 'https://www.example.com/index.html' }
  let(:uri) { URI.parse(url) }

  let(:status) { 200 }
  let(:headers) do
    {
      'Content-Type' => 'text/html; charset=UTF-8',
      'Date'         => 'Wed, 02 Aug 2023 03:52:57 GMT',
      'Server'       => 'ECS (sec/9795)'
    }
  end
  let(:body) do
    <<~HTML
      <html>
        <body>
          <p>Test</p>
        </body>
      </html>
    HTML
  end

  subject { described_class.new(url) }

  describe "#initialize" do
    context "when given a URI" do
      subject { described_class.new(uri) }

      it "must set #uri to the URI object" do
        expect(subject.uri).to eq(uri)
      end
    end

    context "when given a String" do
      subject { described_class.new(url) }

      it "must set #uri to the parsed version of the given URL" do
        expect(subject.uri).to eq(uri)
      end
    end

    context "when the status: keyword argument is given" do
      subject { described_class.new(url, status: status) }

      it "must set #status" do
        expect(subject.status).to eq(status)
      end
    end

    context "when the headers: keyword argument is given" do
      subject { described_class.new(url, headers: headers) }

      it "must set #headers" do
        expect(subject.headers).to eq(headers)
      end
    end

    context "when the body: keyword argument is given" do
      subject { described_class.new(url, body: body) }

      it "must set #body" do
        expect(subject.body).to eq(body)
      end
    end

    context "when given no additional keyword arguments" do
      it "must default #status to nil" do
        expect(subject.status).to be(nil)
      end

      it "must default #headers to nil" do
        expect(subject.headers).to be(nil)
      end

      it "must default #body to nil" do
        expect(subject.body).to be(nil)
      end
    end
  end

  describe "#scheme" do
    it "must return the URI's scheme" do
      expect(subject.scheme).to eq(uri.scheme)
    end
  end

  describe "#userinfo" do
    context "when the URI has userinfo" do
      let(:userinfo) { "user:password" }
      let(:url)      { "https://#{userinfo}@www.example.com/index.html" }

      it "must return the URI's userinfo" do
        expect(subject.userinfo).to eq(userinfo)
      end
    end

    context "when the URI has no userinfo" do
      it "must return nil" do
        expect(subject.userinfo).to be(nil)
      end
    end
  end

  describe "#host" do
    it "must return the URI's host" do
      expect(subject.host).to eq(uri.host)
    end
  end

  describe "#port" do
    it "must return the URI's port" do
      expect(subject.port).to eq(uri.port)
    end
  end

  describe "#path" do
    it "must return the URI's path" do
      expect(subject.path).to eq(uri.path)
    end
  end

  describe "#query" do
    context "when the URI has a query string" do
      let(:query) { "q=1" }
      let(:url)   { "https://www.example.com/page?#{query}" }

      it "must return the URI's query string" do
        expect(subject.query).to eq(query)
      end
    end

    context "when the URI has no query string" do
      it "must return nil" do
        expect(subject.query).to be(nil)
      end
    end
  end

  describe "#eql?" do
    context "when given an URL object" do
      context "and the other URL object has the same #uri" do
        let(:other) { described_class.new(url) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other URL object has a different #uri" do
        let(:other_uri) { URI.parse('https://other.com/index.html') }
        let(:other)     { described_class.new(other_uri) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-URL object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #name" do
      expect(subject.hash).to eq([described_class, uri].hash)
    end
  end

  describe "#to_s" do
    it "must return the String form of #uri" do
      expect(subject.to_s).to eq(url)
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and url: attributes" do
      expect(subject.as_json).to eq({type: :url, url: url})
    end

    context "when #status is set" do
      subject { described_class.new(url, status: status) }

      it "must include the status: attribute in the Hash" do
        expect(subject.as_json).to eq(
          {
            type:   :url,
            url:    url,
            status: status
          }
        )
      end
    end

    context "when #headers is set" do
      subject { described_class.new(url, headers: headers) }

      it "must include the headers: attribute in the Hash" do
        expect(subject.as_json).to eq(
          {
            type:    :url,
            url:     url,
            headers: headers
          }
        )
      end
    end

    context "when #body is set" do
      subject { described_class.new(url, body: body) }

      it "must not include the body: attribute in the Hash" do
        expect(subject.as_json).to eq(
          {
            type: :url,
            url:  url
          }
        )
      end
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :url" do
      expect(subject.value_type).to be(:url)
    end
  end
end
