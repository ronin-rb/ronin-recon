require 'spec_helper'
require 'ronin/recon/output_formats/dir'
require 'tmpdir'

describe Ronin::Recon::OutputFormats::Dir do
  subject { described_class.new(path) }

  let(:path)               { Dir.mktmpdir('ronin-recon-output-dir') }
  let(:values_fixutre_dir) { File.expand_path(File.join(__dir__,'..','values','fixtures')) }
  let(:cert_path)          { File.join(values_fixutre_dir,'example.crt') }

  it "must inherit from Ronin::Core::OutputFormats::OutputDir" do
    expect(described_class).to be < Ronin::Core::OutputFormats::OutputDir
  end

  describe "#<<" do
    context 'for valid value' do
      let(:value) { Ronin::Recon::Values::Domain.new('example.com') }

      it 'must write new value to a domains.txt' do
        subject << value

        expect(File.read(File.join(path, 'domains.txt'))).to eq("example.com#{$/}")
      end
    end

    context 'for Values::Mailserver' do
      let(:value) { Ronin::Recon::Values::Mailserver.new('example.com') }

      it 'must write new value to a mailservers.txt' do
        subject << value

        expect(File.read(File.join(path, 'mailservers.txt'))).to eq("example.com#{$/}")
      end
    end

    context 'for Values::Nameserver' do
      let(:value) { Ronin::Recon::Values::Nameserver.new('example.com') }

      it 'must write new value to a nameservers.txt' do
        subject << value

        expect(File.read(File.join(path, 'nameservers.txt'))).to eq("example.com#{$/}")
      end
    end

    context 'for Values::Host' do
      let(:value) { Ronin::Recon::Values::Host.new('www.example.com') }

      it 'must write new value to a hosts.txt' do
        subject << value

        expect(File.read(File.join(path, 'hosts.txt'))).to eq("www.example.com#{$/}")
      end
    end

    context 'for Values::IP' do
      let(:value) { Ronin::Recon::Values::IP.new('192.168.0.1') }

      it 'must write new value to a ips.txt' do
        subject << value

        expect(File.read(File.join(path, 'ips.txt'))).to eq("192.168.0.1#{$/}")
      end
    end

    context 'for Values::IPRange' do
      let(:value) { Ronin::Recon::Values::IPRange.new('1.2.3.4/24') }

      it 'must write new value to a ip_ranges.txt' do
        subject << value

        expect(File.read(File.join(path, 'ip_ranges.txt'))).to eq("1.2.3.4/24#{$/}")
      end
    end

    context 'for Values::OpenPort' do
      let(:value) { Ronin::Recon::Values::OpenPort.new('192.168.0.1', 80) }

      it 'must write new value to a open_ports.txt' do
        subject << value

        expect(File.read(File.join(path, 'open_ports.txt'))).to eq("192.168.0.1:80#{$/}")
      end
    end

    context 'for Values::EmailAddress' do
      let(:value) { Ronin::Recon::Values::EmailAddress.new('example@example.com') }

      it 'must write new value to a email_addresse.txt' do
        subject << value

        expect(File.read(File.join(path, 'email_addresses.txt'))).to eq("example@example.com#{$/}")
      end
    end

    context 'for Values::Cert' do
      let(:certificate) { File.read(cert_path) }
      let(:cert)        { OpenSSL::X509::Certificate.new(certificate) }
      let(:value)       { Ronin::Recon::Values::Cert.new(cert) }

      it 'must write new value to a certs.txt' do
        subject << value

        expect(File.read(File.join(path, 'certs.txt'))).to eq(certificate)
      end
    end

    context 'for Values::URL' do
      let(:value) { Ronin::Recon::Values::URL.new('https://www.example.com') }

      it 'must write new value to a urls.txt' do
        subject << value

        expect(File.read(File.join(path, 'urls.txt'))).to eq("https://www.example.com#{$/}")
      end
    end

    context 'for Values::Website' do
      let(:value) { Ronin::Recon::Values::Website.new(:https, 'example.com', 443) }

      it 'must write new value to a websites.txt' do
        subject << value

        expect(File.read(File.join(path, 'websites.txt'))).to eq("https://example.com#{$/}")
      end
    end

    context 'for Values::Wildcard' do
      let(:value) { Ronin::Recon::Values::Wildcard.new('*.example.com') }

      it 'must write new value to a wildcards.txt' do
        subject << value

        expect(File.read(File.join(path, 'wildcards.txt'))).to eq("*.example.com#{$/}")
      end
    end

    context 'for invalid value' do
      module TestDotOutputFormat
        class NewValue < Ronin::Recon::Value
        end
      end
      let(:value_class) { TestDotOutputFormat::NewValue }
      let(:value)       { value_class.new }

      it 'must raise a NotImplementedError' do
        expect {
          subject << value
        }.to raise_error(NotImplementedError, "unsupported value class: #{value.inspect}")
      end
    end
  end

  describe "#close" do
    it 'must close all output files' do
      subject.files.each_value do |file|
        expect(file).to receive(:close)
      end

      subject.close
    end
  end
end
