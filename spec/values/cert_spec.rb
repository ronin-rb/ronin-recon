require 'spec_helper'
require 'ronin/recon/values/cert'
require 'ronin/support/crypto'

require 'openssl'

describe Ronin::Recon::Values::Cert do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }
  let(:cert_path)    { File.join(fixtures_dir,'example.crt') }
  let(:cert) do
    Ronin::Support::Crypto::Cert(OpenSSL::X509::Certificate.new(File.read(cert_path)))
  end

  subject { described_class.new(cert) }

  describe "#initialize" do
    it "must set #cert" do
      expect(subject.cert).to eq(cert)
    end
  end

  describe "#serial" do
    it "must return the serial number of the certificate" do
      expect(subject.serial).to eq(cert.serial)
    end
  end

  describe "#not_before" do
    it "must return the serial number of the NotBefore date from the certificate" do
      expect(subject.not_before).to eq(cert.not_before)
    end
  end

  describe "#not_after" do
    it "must return the serial number of the NotAfter date from the certificate" do
      expect(subject.not_after).to eq(cert.not_after)
    end
  end

  describe "#issuer" do
    it "must return the issuer of the certificate" do
      expect(subject.issuer).to eq(cert.issuer)
    end
  end

  describe "#subject" do
    it "must return the subject of the certificate" do
      expect(subject.subject).to eq(cert.subject)
    end
  end

  describe "#extensions" do
    it "must return the extensions of the certificate" do
      expect(subject.extensions).to eq(cert.extensions)
    end
  end

  describe "#eql?" do
    context "when given an Cert object" do
      context "and the other Cert object has the same #cert" do
        let(:other) { described_class.new(cert) }

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other Cert object has a different #cert" do
        let(:other_cert_path) { File.join(fixtures_dir,'other.crt') }
        let(:other_cert) do
          OpenSSL::X509::Certificate.new(File.read(other_cert_path))
        end
        let(:other) { described_class.new(other_cert) }

        it "must return true" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    context "when given a non-Cert object" do
      let(:other) { Object.new }

      it "must return false" do
        expect(subject.eql?(other)).to be(false)
      end
    end
  end

  describe "#hash" do
    it "must return the #hash of an Array containing the class and the #cert's serial number" do
      expect(subject.hash).to eq([described_class, cert.serial].hash)
    end
  end

  describe "#to_s" do
    it "must return the String version of #cert" do
      expect(subject.to_s).to eq(cert.to_s)
    end
  end

  describe "#as_json" do
    let(:cert_hash) {
      {
        subject: cert.subject.to_h,
        issuer: cert.issuer.to_h,
        extensions: cert.extensions_hash,
        serial: cert.serial,
        not_before: cert.not_before,
        not_after: cert.not_after
      }
    }

    it "must return the Hash version of #cert" do
      expect(subject.as_json).to eq(cert_hash)
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :cert" do
      expect(subject.value_type).to be(:cert)
    end
  end
end
