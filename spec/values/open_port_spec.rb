require 'spec_helper'
require 'ronin/recon/values/open_port'

describe Ronin::Recon::Values::OpenPort do
  let(:address)  { '93.184.216.34' }
  let(:number)   { 80 }
  let(:host)     { 'example.com' }
  let(:protocol) { :tcp }
  let(:service)  { 'http' }
  let(:ssl)      { false }

  subject do
    described_class.new(address,number, protocol: protocol,
                                        service:  service,
                                        ssl:      ssl)
  end

  describe "#initialize" do
    subject { described_class.new(address,number) }

    it "must set #address" do
      expect(subject.address).to eq(address)
    end

    it "must set #number" do
      expect(subject.number).to eq(number)
    end

    it "must default #host to nil" do
      expect(subject.host).to be(nil)
    end

    it "must default #protocol to :tcp" do
      expect(subject.protocol).to be(:tcp)
    end

    it "must default #service to nil" do
      expect(subject.service).to be(nil)
    end

    it "must default #ssl to false" do
      expect(subject.ssl).to be(false)
    end

    context "when the host: keyword argument is given" do
      subject { described_class.new(address,number, host: host) }

      it "must set #host" do
        expect(subject.host).to eq(host)
      end
    end

    context "when the protocol: keyword argument is given" do
      subject { described_class.new(address,number, protocol: protocol) }

      it "must set #protocol" do
        expect(subject.protocol).to eq(protocol)
      end
    end

    context "when the service: keyword argument is given" do
      subject { described_class.new(address,number, service: service) }

      it "must set #service" do
        expect(subject.service).to eq(service)
      end
    end

    context "when the ssl: keyword argument is given" do
      subject { described_class.new(address,number, ssl: ssl) }

      it "must set #ssl" do
        expect(subject.ssl).to eq(ssl)
      end
    end
  end

  describe "#eql?" do
    context "when given an OpenPort object" do
      context "and the other OpenPort object has the same #address, #number, #protocol, #service, and #ssl" do
        let(:other) do
          described_class.new(address,number, protocol: protocol,
                                              service:  service,
                                              ssl:      ssl)
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other OpenPort object has a different #address" do
        let(:other) do
          described_class.new('127.0.0.1',number, protocol: protocol,
                                                  service:  service,
                                                  ssl:      ssl)
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other OpenPort object has a different #number" do
        let(:other) do
          described_class.new(address,8000, protocol: protocol,
                                            service:  service,
                                            ssl:      ssl)
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other OpenPort object has a different #protocol" do
        let(:other) do
          described_class.new(address,number, protocol: :udp,
                                              service:  service,
                                              ssl:      ssl)
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other OpenPort object has a different #service" do
        let(:other) do
          described_class.new(address,number, protocol: protocol,
                                              service:  'unknown',
                                              ssl:      ssl)
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other OpenPort object has a different #ssl" do
        let(:other) do
          described_class.new(address,number, protocol: protocol,
                                              service:  service,
                                              ssl:      true)
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-OpenPort object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #address, #number, #protocol, #service, and #ssl" do
      expect(subject.hash).to eq([described_class, address, number, protocol, service, ssl].hash)
    end
  end

  describe "#to_s" do
    it "must return a String with the address:port pair" do
      expect(subject.to_s).to eq("#{address}:#{number}")
    end
  end

  describe "#to_i" do
    it "must return the #number" do
      expect(subject.to_i).to eq(number)
    end
  end

  describe "#as_json" do
    let(:service) { nil }

    it "must return a Hash containing the type: and address:, number:, and protocol: attributes" do
      expect(subject.as_json).to eq(
        {
          type:     :open_port,
          address:  address,
          protocol: protocol,
          number:   number
        }
      )
    end

    context "when #service is set" do
      let(:service) { 'http' }

      it "must include the service: attribute" do
        expect(subject.as_json).to eq(
          {
            type:     :open_port,
            address:  address,
            protocol: protocol,
            number:   number,
            service:  service
          }
        )
      end
    end

    context "when #ssl is set" do
      let(:ssl) { true }

      it "must include the ssl: attribute" do
        expect(subject.as_json).to eq(
          {
            type:     :open_port,
            address:  address,
            protocol: protocol,
            number:   number,
            ssl:      ssl
          }
        )
      end
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :open_port" do
      expect(subject.value_type).to be(:open_port)
    end
  end
end
