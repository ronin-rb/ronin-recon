require 'spec_helper'
require 'ronin/recon/values/web_socket'

describe Ronin::Recon::Values::WebSocket do
  let(:scheme) { 'ws' }
  let(:host)   { 'example.com' }
  let(:port)   { 80 }
  let(:path)   { '/path' }
  let(:query)  { 'foo=bar' }
  let(:url)    { "#{scheme}://#{host}:#{port}#{path}?#{query}" }

  subject { described_class.new(url) }

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

    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must set #query" do
      expect(subject.query).to eq(query)
    end
  end

  describe ".wss" do
    subject { described_class.wss(host,port,path,query) }

    it "must create a WebSocket object with #scheme of 'wss'" do
      expect(subject.scheme).to eq('wss')
    end

    it "must set #host" do
      expect(subject.host).to eq(host)
    end

    it "must set #port" do
      expect(subject.port).to eq(port)
    end

    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must set #query" do
      expect(subject.query).to eq(query)
    end
  end

  describe ".ws" do
    subject { described_class.ws(host,port,path,query) }

    it "must create a WebSocket object with #scheme of 'ws'" do
      expect(subject.scheme).to eq('ws')
    end

    it "must set #host" do
      expect(subject.host).to eq(host)
    end

    it "must set #port" do
      expect(subject.port).to eq(port)
    end

    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must set #query" do
      expect(subject.query).to eq(query)
    end
  end

  describe "#eql?" do
    context "when given an WebSocket object" do
      context "and the other WebSocket object has the same #scheme, #host, #port, #path and #query" do
        let(:other) { described_class.new(url) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other WebSocket object has a different #scheme" do
        let(:other_url) { "wss://#{host}:#{port}#{path}?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other WebSocket object has a different #host" do
        let(:other_url) { "#{scheme}://other.com:#{port}#{path}?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other WebSocket object has a different #port" do
        let(:other_url) { "#{scheme}://#{host}:8000#{path}?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other WebSocket object has a different #path" do
        let(:other_url) { "#{scheme}://#{host}:#{port}/not_path?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other WebSocket object has a different #query" do
        let(:other_url) { "#{scheme}://#{host}:#{port}#{path}?different=query" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-WebSocket object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#===" do
    context "when given an WebSocket object" do
      context "and the other WebSocket object has the same #scheme, #host, #port, #path and #query" do
        let(:other) { described_class.new(url) }

        it "must return true" do
          expect(subject === other).to be(true)
        end
      end

      context "but the other WebSocket object has a different #scheme" do
        let(:other_url) { "wss://#{host}:#{port}#{path}?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other WebSocket object has a different #host" do
        let(:other_url) { "#{scheme}://other.com:#{port}#{path}?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other WebSocket object has a different #port" do
        let(:other_url) { "#{scheme}://#{host}:8000#{path}?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other WebSocket object has a different #path" do
        let(:other_url) { "#{scheme}://#{host}:#{port}/not_path?#{query}" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end

      context "but the other WebSocket object has a different #query" do
        let(:other_url) { "#{scheme}://#{host}:#{port}#{path}?different=query" }
        let(:other)     { described_class.new(other_url) }

        it "must return false" do
          expect(subject === other).to be(false)
        end
      end
    end

    context "when given a non-WebSocket object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject === other).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #scheme, #host, and #port" do
      expect(subject.hash).to eq([described_class, scheme, host, port, path, query].hash)
    end
  end

  describe "#to_uri" do
    context "when the #scheme is wss" do
      let(:scheme) { 'wss' }

      it "must return URI object with 'wss' scheme" do
        uri = subject.to_uri

        expect(uri.scheme).to eq('wss')
        expect(uri.host).to eq(host)
        expect(uri.port).to eq(port)
        expect(uri.path).to eq(path)
        expect(uri.query).to eq(query)
      end
    end

    context "when the #scheme is ws" do
      let(:scheme) { 'ws' }

      it "must return URI object with 'ws' scheme" do
        uri = subject.to_uri

        expect(uri.scheme).to eq('ws')
        expect(uri.host).to eq(host)
        expect(uri.port).to eq(port)
        expect(uri.path).to eq(path)
        expect(uri.query).to eq(query)
      end
    end
  end

  describe "#to_s" do
    it "must return a String URL for the WebSocket" do
      expect(subject.to_s).to eq("#{scheme}://#{host}#{path}?#{query}")
    end

    context "when the #scheme is 'ws'" do
      let(:scheme) { 'ws' }

      context "and the #port is 80" do
        let(:port) { 80 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}#{path}?#{query}")
        end
      end

      context "but the #port is not 80" do
        let(:port) { 8000 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}:#{port}#{path}?#{query}")
        end
      end
    end

    context "when the #scheme is 'wss'" do
      let(:scheme) { 'wss' }

      context "and the #port is 443" do
        let(:port) { 443 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}#{path}?#{query}")
        end
      end

      context "but the #port is not 443" do
        let(:port) { 9000 }

        it "must omit the port from the URL String" do
          expect(subject.to_s).to eq("#{scheme}://#{host}:#{port}#{path}?#{query}")
        end
      end
    end
  end

  describe "#as_json" do
    it "must return a Hash containing the type: and scheme:, host:, and port: attributes" do
      expect(subject.as_json).to eq(
        {
          type:   :web_socket,
          scheme: scheme,
          host:   host,
          port:   port,
          path:   path,
          query:  query
        }
      )
    end
  end

  describe ".value_type" do
    it "must return :web_socket" do
      expect(described_class.value_type).to eq(:web_socket)
    end
  end
end
