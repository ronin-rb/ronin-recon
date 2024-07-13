require 'spec_helper'
require 'ronin/recon/cli/printing'
require 'ronin/recon/cli/command'

describe Ronin::Recon::CLI::Printing do
  module TestPrinting
    class TestCommand < Ronin::Recon::CLI::Command
      include Ronin::Recon::CLI::Printing
    end
  end

  let(:command_class) { TestPrinting::TestCommand }
  subject { command_class.new }

  let(:fixtures_dir) { File.join(__dir__,'..','fixtures') }

  describe "#value_class_name" do
    context "when given Ronin::Recon::Values::Domain" do
      let(:value_class) { Ronin::Recon::Values::Domain }

      it "must return 'domain'" do
        expect(subject.value_class_name(value_class)).to eq("domain")
      end
    end

    context "when given Ronin::Recon::Values::Mailserver" do
      let(:value_class) { Ronin::Recon::Values::Mailserver }

      it "must return 'mailserver'" do
        expect(subject.value_class_name(value_class)).to eq("mailserver")
      end
    end

    context "when given Ronin::Recon::Values::Nameserver" do
      let(:value_class) { Ronin::Recon::Values::Nameserver }

      it "must return 'nameserver'" do
        expect(subject.value_class_name(value_class)).to eq("nameserver")
      end
    end

    context "when given Ronin::Recon::Values::Host" do
      let(:value_class) { Ronin::Recon::Values::Host }

      it "must return 'host'" do
        expect(subject.value_class_name(value_class)).to eq("host")
      end
    end

    context "when given Ronin::Recon::Values::IP" do
      let(:value_class) { Ronin::Recon::Values::IP }

      it "must return 'IP address'" do
        expect(subject.value_class_name(value_class)).to eq("IP address")
      end
    end

    context "when given Ronin::Recon::Values::IPRange" do
      let(:value_class) { Ronin::Recon::Values::IPRange }

      it "must return 'IP range'" do
        expect(subject.value_class_name(value_class)).to eq("IP range")
      end
    end

    context "when given Ronin::Recon::Values::OpenPort" do
      let(:value_class) { Ronin::Recon::Values::OpenPort }

      it "must return 'open port'" do
        expect(subject.value_class_name(value_class)).to eq("open port")
      end
    end

    context "when given Ronin::Recon::Values::Cert" do
      let(:value_class) { Ronin::Recon::Values::Cert }

      it "must return 'SSL/TLS certificate'" do
        expect(subject.value_class_name(value_class)).to eq("SSL/TLS certificate")
      end
    end

    context "when given Ronin::Recon::Values::URL" do
      let(:value_class) { Ronin::Recon::Values::URL }

      it "must return 'URL'" do
        expect(subject.value_class_name(value_class)).to eq("URL")
      end
    end

    context "when given Ronin::Recon::Values::Website" do
      let(:value_class) { Ronin::Recon::Values::Website }

      it "must return 'website'" do
        expect(subject.value_class_name(value_class)).to eq("website")
      end
    end

    context "when given a Ronin::Recon::Values::Wildcard" do
      let(:value_class) { Ronin::Recon::Values::Wildcard }

      it "must return 'wildcard host name'" do
        expect(subject.value_class_name(value_class)).to eq("wildcard host name")
      end
    end

    context "when given another kind of Ronin::Recon::Value sub-class" do
      module TestPrinting
        class OtherValue < Ronin::Recon::Value
        end
      end

      let(:value_class) { TestPrinting::OtherValue }

      it do
        expect {
          subject.value_class_name(value_class)
        }.to raise_error(NotImplementedError,"unknown value class: #{value_class.inspect}")
      end
    end

    context "when given another kind of Object" do
      let(:value_class) { Object }

      it do
        expect {
          subject.value_class_name(value_class)
        }.to raise_error(NotImplementedError,"unknown value class: #{value_class.inspect}")
      end
    end
  end

  describe "#format_value" do
    context "when given a Ronin::Recon::Values::Domain value" do
      let(:value) do
        Ronin::Recon::Values::Domain.new('example.com')
      end

      it "must return 'domain \#{value}'" do
        expect(subject.format_value(value)).to eq("domain #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::Mailserver value" do
      let(:value) do
        Ronin::Recon::Values::Mailserver.new('smtp.example.com')
      end

      it "must return 'mailserver \#{value}'" do
        expect(subject.format_value(value)).to eq("mailserver #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::Nameserver value" do
      let(:value) do
        Ronin::Recon::Values::Nameserver.new('1.1.1.1')
      end

      it "must return 'nameserver \#{value}'" do
        expect(subject.format_value(value)).to eq("nameserver #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::Host value" do
      let(:value) do
        Ronin::Recon::Values::Host.new('www.example.com')
      end

      it "must return 'host \#{value}'" do
        expect(subject.format_value(value)).to eq("host #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::IP value" do
      let(:value) do
        Ronin::Recon::Values::IP.new('192.168.1.1')
      end

      it "must return 'IP address \#{value}'" do
        expect(subject.format_value(value)).to eq("IP address #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::IPRange value" do
      let(:value) do
        Ronin::Recon::Values::IPRange.new('192.168.1.1/24')
      end

      it "must return 'IP range \#{value}'" do
        expect(subject.format_value(value)).to eq("IP range #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::OpenPort value" do
      let(:value) do
        Ronin::Recon::Values::OpenPort.new(
          address, number, host:     host,
                           protocol: protocol,
                           service:  service,
                           ssl:      ssl
        )
      end

      context "and when the Ronin::Recon::Values::OpenPort's #protocol is :tcp" do
        let(:address)  { '192.168.1.1' }
        let(:number)   { 443 }
        let(:host)     { 'www.example.com' }
        let(:protocol) { :tcp }
        let(:service)  { 'https' }
        let(:ssl)      { true }

        it "must return 'open TCP port \#{value}'" do
          expect(subject.format_value(value)).to eq("open TCP port #{value}")
        end
      end

      context "and when the Ronin::Recon::Values::OpenPort's #protocol is :udp" do
        let(:address)  { '192.168.1.1' }
        let(:number)   { 53 }
        let(:host)     { 'www.example.com' }
        let(:protocol) { :udp }
        let(:service)  { 'dns' }
        let(:ssl)      { false }

        it "must return 'open UDP port \#{value}'" do
          expect(subject.format_value(value)).to eq("open UDP port #{value}")
        end
      end
    end

    context "when given a Ronin::Recon::Values::Cert value" do
      let(:cert_path) { File.join(fixtures_dir,'values','cert.crt') }
      let(:cert)      { Ronin::Support::Crypto::Cert.load_file(cert_path) }
      let(:value)     { Ronin::Recon::Values::Cert.new(cert) }

      it "must return 'SSL/TLS certificate \#{value.subject}'" do
        expect(subject.format_value(value)).to eq("SSL/TLS certificate #{value.subject}")
      end
    end

    context "when given a Ronin::Recon::Values::URL value" do
      let(:value) do
        Ronin::Recon::Values::URL.new('https://example.com/page.html')
      end

      it "must return 'URL \#{value}'" do
        expect(subject.format_value(value)).to eq("URL #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::Website value" do
      let(:value) do
        Ronin::Recon::Values::Website.new(:https,'example.com',443)
      end

      it "must return 'website \#{value}'" do
        expect(subject.format_value(value)).to eq("website #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::Wildcard value" do
      let(:value) do
        Ronin::Recon::Values::Wildcard.new('*.example.com')
      end

      it "must return 'wildcard host name \#{value}'" do
        expect(subject.format_value(value)).to eq("wildcard host name #{value}")
      end
    end

    context "when given a Ronin::Recon::Values::EmailAddress value" do
      let(:value) do
        Ronin::Recon::Values::EmailAddress.new('bob@example.com')
      end

      it "must return 'email address \#{value}'" do
        expect(subject.format_value(value)).to eq("email address #{value}")
      end
    end

    context "when given another kind of Ronin::Recon::Value object" do
      module TestPrinting
        class OtherValue < Ronin::Recon::Value
        end
      end

      let(:value) { TestPrinting::OtherValue.new }

      it do
        expect {
          subject.format_value(value)
        }.to raise_error(NotImplementedError,"value class #{value.class} not supported")
      end
    end

    context "when given another kind of Object" do
      let(:value) { Object.new }

      it do
        expect {
          subject.format_value(value)
        }.to raise_error(NotImplementedError,"value class #{value.class} not supported")
      end
    end
  end

  describe "#print_value" do
    let(:stdout) { StringIO.new }

    subject { command_class.new(stdout: stdout) }

    let(:value) { Ronin::Recon::Values::Host.new('www.example.com') }

    context "when STDOUT is a TTY" do
      before { expect(stdout).to receive(:tty?).and_return(true) }

      it "must log 'Found new \#{format_value(value)}'" do
        expect(subject).to receive(:log_info).with("Found new #{subject.format_value(value)}")

        subject.print_value(value)
      end

      context "when given a parent value" do
        let(:parent) { Ronin::Recon::Values::Domain.new('example.com') }

        it "must log 'Found new \#{format_value(value)} for \#{format_value(parent)}'" do
          expect(subject).to receive(:log_info).with("Found new #{subject.format_value(value)} for #{subject.format_value(parent)}")

          subject.print_value(value,parent)
        end
      end
    end

    context "when STDOUT is not a TTY" do
      before { allow(stdout).to receive(:tty?).and_return(false) }

      it "must print the value to STDOUT" do
        expect(subject).to receive(:puts).with(value)

        subject.print_value(value)
      end
    end
  end
end
