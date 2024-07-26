require 'spec_helper'
require 'ronin/recon/importer'
require 'ronin/db'

RSpec.describe Ronin::Recon::Importer do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  before(:all) do
    Ronin::DB.connect('sqlite3::memory:')
  end

  after do
    Ronin::DB::URL.destroy_all
    Ronin::DB::Cert.destroy_all
    Ronin::DB::HostName.destroy_all
    Ronin::DB::OpenPort.destroy_all
    Ronin::DB::Service.destroy_all
    Ronin::DB::Port.destroy_all
    Ronin::DB::IPAddress.destroy_all
  end

  describe ".import_connection" do
    let(:value)  { Ronin::Recon::Values::Host.new('www.example.com') }
    let(:parent) { Ronin::Recon::Values::Domain.new('example.com') }

    it "must return both the imported value and parent value" do
      imported_value, imported_parent = subject.import_connection(value,parent)

      expect(imported_value).to be_kind_of(Ronin::DB::HostName)
      expect(imported_value.name).to eq(value.name)
      expect(imported_parent).to be_kind_of(Ronin::DB::HostName)
      expect(imported_parent.name).to eq(parent.name)
    end

    context "when the value is Ronin::Recon::Values::IP" do
      let(:value)  { Ronin::Recon::Values::IP.new('192.168.1.1') }

      context "and the parent value is a Ronin::Recon::Values::Host" do
        let(:parent) { Ronin::Recon::Values::Host.new('www.example.com') }

        it "must associate the Ronin::DB::IPAddress with the Ronin::DB::HostName" do
          imported_ip_address, imported_host_name = subject.import_connection(value,parent)

          expect(imported_ip_address).to be_kind_of(Ronin::DB::IPAddress)
          expect(imported_ip_address.address).to eq(value.address)
          expect(imported_ip_address.host_names.length).to eq(1)
          expect(imported_ip_address.host_names[0]).to eq(imported_host_name)
          expect(imported_host_name).to be_kind_of(Ronin::DB::HostName)
          expect(imported_host_name.name).to eq(parent.name)
        end
      end
    end

    context "when the value is a Ronin::Recon::Values::Cert" do
      let(:cert_path) { File.join(fixtures_dir,'certs','example.crt') }
      let(:cert)      { Ronin::Support::Crypto::Cert.load_file(cert_path) }
      let(:value)     { Ronin::Recon::Values::Cert.new(cert) }

      context "and the parent value is a Ronin::Recon::Values::OpenPort" do
        let(:address)  { '192.168.1.1' }
        let(:protocol) { :tcp }
        let(:number)   { 443 }
        let(:parent) do
          Ronin::Recon::Values::OpenPort.new(
            address, number, protocol: protocol
          )
        end

        it "must associate the Ronin::DB::Cert with the Ronin::DB::OpenPort" do
          imported_cert, imported_open_port = subject.import_connection(value,parent)

          expect(imported_cert).to be_kind_of(Ronin::DB::Cert)
          expect(imported_cert.to_s).to eq(cert.to_s)
          expect(imported_cert.open_ports.length).to eq(1)
          expect(imported_cert.open_ports[0]).to eq(imported_open_port)
          expect(imported_open_port).to be_kind_of(Ronin::DB::OpenPort)
          expect(imported_open_port.ip_address.address).to eq(address)
          expect(imported_open_port.number).to eq(number)
        end
      end
    end
  end

  describe ".import_value" do
    context "when the value is a Ronin::Recon::Values::Host" do
      let(:name)  { 'www.example.com' }
      let(:value) { Ronin::Recon::Values::Host.new(name) }

      it "must import and return a Ronin::DB::HostName" do
        result = subject.import_value(value)

        expect(result).to be_kind_of(Ronin::DB::HostName)
        expect(result.name).to eq(name)
      end
    end

    context "when the value is a Ronin::Recon::Values::IP" do
      let(:address) { '192.168.1.1' }
      let(:value)   { Ronin::Recon::Values::IP.new(address) }

      it "must import and return a Ronin::DB::IPAddress" do
        result = subject.import_value(value)

        expect(result).to be_kind_of(Ronin::DB::IPAddress)
        expect(result.address).to eq(address)
      end
    end

    context "when the value is a Ronin::Recon::Values::OpenPort" do
      let(:address)  { '192.168.1.1' }
      let(:protocol) { :tcp }
      let(:number)   { 80 }
      let(:value) do
        Ronin::Recon::Values::OpenPort.new(
          address, number, protocol: protocol
        )
      end

      it "must import and return a Ronin::DB::OpenPort" do
        result = subject.import_value(value)

        expect(result).to be_kind_of(Ronin::DB::OpenPort)
        expect(result.ip_address.address).to eq(address)
        expect(result.port.number).to eq(number)
        expect(result.port.protocol).to eq(protocol.to_s)
        expect(result.service).to be(nil)
      end
    end

    context "when the value is a Ronin::Recon::Values::URL" do
      let(:url)   { 'https://example.com/page.html' }
      let(:value) { Ronin::Recon::Values::URL.new(url) }

      it "must import and return a Ronin::DB::URL" do
        result = subject.import_value(value)

        expect(result).to be_kind_of(Ronin::DB::URL)
        expect(result.to_s).to eq(url)
      end
    end

    context "when the value is a Ronin::Recon::Values::Cert" do
      let(:cert_path) { File.join(fixtures_dir,'certs','example.crt') }
      let(:cert)      { Ronin::Support::Crypto::Cert.load_file(cert_path) }
      let(:value)     { Ronin::Recon::Values::Cert.new(cert) }

      it "must import and return a Ronin::DB::Cert" do
        result = subject.import_value(value)

        expect(result).to be_kind_of(Ronin::DB::Cert)
        expect(result.to_s).to eq(cert.to_s)
      end
    end
  end

  describe ".import_host_name" do
    let(:name) { 'www.example.com' }

    it "must import and return a Ronin::DB::HostName" do
      result = subject.import_host_name(name)

      expect(result).to be_kind_of(Ronin::DB::HostName)
      expect(result.name).to eq(name)
    end
  end

  describe ".import_ip_address" do
    let(:address) { '192.168.1.1' }

    it "must import and return a Ronin::DB::IPAddress" do
      result = subject.import_ip_address(address)

      expect(result).to be_kind_of(Ronin::DB::IPAddress)
      expect(result.address).to eq(address)
    end
  end

  describe ".import_url" do
    let(:url) { 'https://example.com/page.html' }

    it "must import and return a Ronin::DB::URL" do
      result = subject.import_url(url)

      expect(result).to be_kind_of(Ronin::DB::URL)
      expect(result.to_s).to eq(url)
    end
  end

  describe ".import_port" do
    let(:protocol) { :tcp }
    let(:number)   { 80 }

    it "must import and return a Ronin::DB::Port" do
      result = subject.import_port(protocol,number)

      expect(result).to be_kind_of(Ronin::DB::Port)
      expect(result.protocol).to eq(protocol.to_s)
      expect(result.number).to eq(number)
    end
  end

  describe ".import_service" do
    let(:service) { 'ssh' }

    it "must import and return a Ronin::DB::Service" do
      result = subject.import_service(service)

      expect(result).to be_kind_of(Ronin::DB::Service)
      expect(result.name).to eq(service)
    end
  end

  describe ".import_open_port" do
    let(:address)  { '192.168.1.1' }
    let(:number)   { 22 }
    let(:protocol) { :tcp }
    let(:value) do
      Ronin::Recon::Values::OpenPort.new(
        address, number, protocol: protocol
      )
    end

    it "must import and return a Ronin::DB::OpenPort" do
      result = subject.import_open_port(value)

      expect(result).to be_kind_of(Ronin::DB::OpenPort)
      expect(result.ip_address.address).to eq(address)
      expect(result.port.number).to eq(number)
      expect(result.port.protocol).to eq(protocol.to_s)
      expect(result.service).to be(nil)
    end

    context "when the open port value has a #service" do
      let(:service) { 'ssh' }
      let(:value) do
        Ronin::Recon::Values::OpenPort.new(
          address, number, protocol: protocol,
                           service:  service
        )
      end

      it "must import and return a Ronin::DB::OpenPort with a #service" do
        result = subject.import_open_port(value)

        expect(result).to be_kind_of(Ronin::DB::OpenPort)
        expect(result.ip_address.address).to eq(address)
        expect(result.port.number).to eq(number)
        expect(result.port.protocol).to eq(protocol.to_s)
        expect(result.service.name).to eq(service)
      end
    end
  end

  describe ".import_cert" do
    let(:cert_path) { File.join(fixtures_dir,'certs','example.crt') }
    let(:cert)      { Ronin::Support::Crypto::Cert.load_file(cert_path) }

    it "must import and return a Ronin::DB::Cert" do
      result = subject.import_cert(cert)

      expect(result).to be_kind_of(Ronin::DB::Cert)
      expect(result.to_s).to eq(cert.to_s)
    end
  end
end
