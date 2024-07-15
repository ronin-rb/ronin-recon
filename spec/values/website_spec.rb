require 'spec_helper'
require 'ronin/recon/values/website'

describe Ronin::Recon::Values::Website do
  let(:scheme) { 'http' }
  let(:host)   { 'example.com' }
  let(:port)   { 80 }

  subject { described_class.new(scheme,host,port) }

  describe "#initialize" do
    it "must set #scheme" do
      expect(subject.scheme).to eq(scheme)
    end

    it "must set #host" do
      expect(subject.host).to eq(host)
    end

    it "must set #port" do
      expect(subject.port).to eq(port)
    end
  end

  describe ".http" do
    subject { described_class.http(host,port) }

    it "must create a Website object with #scheme of 'http'" do
      expect(subject.scheme).to eq('http')
    end

    it "must set #host" do
      expect(subject.host).to eq(host)
    end

    it "must set #port" do
      expect(subject.port).to eq(port)
    end
  end

  describe ".https" do
    subject { described_class.https(host,port) }

    it "must create a Website object with #scheme of 'https'" do
      expect(subject.scheme).to eq('https')
    end

    it "must set #host" do
      expect(subject.host).to eq(host)
    end

    it "must set #port" do
      expect(subject.port).to eq(port)
    end
  end

  describe ".parse" do
    subject { described_class }

    let(:host)   { 'example.com' }
    let(:string) { "#{scheme}://#{host}" }

    context "and the string starts with 'http://'" do
      let(:scheme) { 'http' }

      it "must return a Values::Website object with a 'http' scheme, host, and port of 443" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::Website)
        expect(value.scheme).to eq(scheme)
        expect(value.host).to eq(host)
        expect(value.port).to eq(80)
      end

      context "and the base URL contains a custom port" do
        let(:port)   { 8080 }
        let(:string) { "#{scheme}://#{host}:#{port}" }

        it "must set the port" do
          value = subject.parse(string)

          expect(value).to be_kind_of(Ronin::Recon::Values::Website)
          expect(value.scheme).to eq(scheme)
          expect(value.host).to eq(host)
          expect(value.port).to eq(port)
        end
      end
    end

    context "and the string starts with 'https://'" do
      let(:scheme) { 'https' }

      it "must return a Values::Website object with a 'https' scheme, host, and port of 443" do
        value = subject.parse(string)

        expect(value).to be_kind_of(Ronin::Recon::Values::Website)
        expect(value.scheme).to eq(scheme)
        expect(value.host).to eq(host)
        expect(value.port).to eq(443)
      end

      context "and the base URL contains a custom port" do
        let(:port)   { 8080 }
        let(:string) { "#{scheme}://#{host}:#{port}" }

        it "must set the port" do
          value = subject.parse(string)

          expect(value).to be_kind_of(Ronin::Recon::Values::Website)
          expect(value.scheme).to eq(scheme)
          expect(value.host).to eq(host)
          expect(value.port).to eq(port)
        end
      end
    end
  end

  describe "#eql?" do
    context "when given an Website object" do
      context "and the other Website object has the same #scheme, #host, and #port" do
        let(:other) { described_class.new(scheme,host,port) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other Website object has a different #scheme" do
        let(:other) { described_class.new('https',host,port) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other Website object has a different #host" do
        let(:other) { described_class.new(scheme,'other.com',port) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other Website object has a different #port" do
        let(:other) { described_class.new(scheme,host,8000) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-Website object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#===" do
    context "when given a Website object" do
      context "and it is equal to the other Website value" do
        let(:other) { described_class.new(scheme,host,port) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other Website value has a different scheme" do
        let(:other) do
          described_class.new('https',host,port)
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other Website value has a different host" do
        let(:other) do
          described_class.new(scheme,'other.com',port)
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other Website value has a different port" do
        let(:other) do
          described_class.new(scheme,host,8000)
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given a URL object" do
      context "and the other URL object has the same scheme, host, and port" do
        let(:other) do
          Ronin::Recon::Values::URL.new("#{scheme}://#{host}:#{port}")
        end

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other URL object has a different scheme" do
        let(:other) do
          Ronin::Recon::Values::URL.new("https://#{host}:#{port}")
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other URL object has a different host" do
        let(:other) do
          Ronin::Recon::Values::URL.new("#{scheme}://other.com:#{port}")
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other URL object has a different port" do
        let(:other) do
          Ronin::Recon::Values::URL.new("#{scheme}://#{host}:8000")
        end

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given a non-Value object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject === other).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #scheme, #host, and #port" do
      expect(subject.hash).to eq([described_class, scheme, host, port].hash)
    end
  end

  describe "#to_uri" do
    context "when the #scheme is 'http'" do
      let(:scheme) { 'http' }

      it "must return a URI::HTTP object with the #host, #port, and path of '/'" do
        expect(subject.to_uri).to eq(
          URI::HTTP.build(
            host: host,
            port: port,
            path: '/'
          )
        )
      end
    end

    context "when the #scheme is 'https'" do
      let(:scheme) { 'https' }

      it "must return a URI::HTTPS object with the #host, #port, and path of '/'" do
        expect(subject.to_uri).to eq(
          URI::HTTPS.build(
            host: host,
            port: port,
            path: '/'
          )
        )
      end
    end
  end

  describe "#to_s" do
    it "must return a String URL for the website" do
      expect(subject.to_s).to eq("#{scheme}://#{host}")
    end

    context "when the #scheme is 'http'" do
      let(:scheme) { 'http' }

      context "and the #port is 80" do
        let(:port) { 80 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}")
        end
      end

      context "but the #port is not 80" do
        let(:port) { 8000 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}:#{port}")
        end
      end
    end

    context "when the #scheme is 'https'" do
      let(:scheme) { 'https' }

      context "and the #port is 443" do
        let(:port) { 443 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}")
        end
      end

      context "but the #port is not 443" do
        let(:port) { 9000 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}:#{port}")
        end
      end
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and scheme:, host:, and port: attributes" do
      expect(subject.as_json).to eq(
        {
          type:   :website,
          scheme: scheme,
          host:   host,
          port:   port
        }
      )
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :website" do
      expect(subject.value_type).to be(:website)
    end
  end
end
