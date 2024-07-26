require 'spec_helper'
require 'ronin/recon/output_formats/dot'
require 'stringio'

describe Ronin::Recon::OutputFormats::Dot do
  subject { described_class.new(io) }

  let(:io) { StringIO.new }

  let(:fixtures_dir) { File.expand_path(File.join(__dir__,'..','fixtures')) }
  let(:cert_path)    { File.join(fixtures_dir,'certs','example.crt') }
  let(:cert)         { OpenSSL::X509::Certificate.new(File.read(cert_path)) }

  it 'must inherit from Ronin::Core::OutputFormats::OutputFile' do
    expect(described_class).to be < Ronin::Core::OutputFormats::OutputFile
  end

  describe '#value_type' do
    context 'for Values::Domain' do
      let(:value) { Ronin::Recon::Values::Domain.new('example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Domain')
      end
    end

    context 'for Values::Mailserver' do
      let(:value) { Ronin::Recon::Values::Mailserver.new('example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Mailserver')
      end
    end

    context 'for Values::Nameserver' do
      let(:value) { Ronin::Recon::Values::Nameserver.new('example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Nameserver')
      end
    end

    context 'for Values::Host' do
      let(:value) { Ronin::Recon::Values::Host.new('www.example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Host')
      end
    end

    context 'for Values::IP' do
      let(:value) { Ronin::Recon::Values::IP.new('192.168.0.1') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('IP address')
      end
    end

    context 'for Values::IPRange' do
      let(:value) { Ronin::Recon::Values::IPRange.new('1.2.3.4/24') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('IP range')
      end
    end

    context 'for Values::OpenPort' do
      let(:value) { Ronin::Recon::Values::OpenPort.new('192.168.0.1', 80) }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Open TCP Port')
      end
    end

    context 'for Values::EmailAddress' do
      let(:value) { Ronin::Recon::Values::EmailAddress.new('example@example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Email Address')
      end
    end

    context 'for Values::Cert' do
      let(:value) { Ronin::Recon::Values::Cert.new(cert) }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('SSL/TLS Cert')
      end
    end

    context 'for Values::URL' do
      let(:value) { Ronin::Recon::Values::URL.new('https://www.example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('URL')
      end
    end

    context 'for Values::Website' do
      let(:value) { Ronin::Recon::Values::Website.new(:https, 'example.com', 443) }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Website')
      end
    end

    context 'for Values::Wildcard' do
      let(:value) { Ronin::Recon::Values::Wildcard.new('*.example.com') }

      it 'must return descriptive type name' do
        expect(subject.value_type(value)).to eq('Wildcard')
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
          subject.value_type(value)
        }.to raise_error(NotImplementedError, "value class #{value.class} not supported")
      end
    end
  end

  context '#value_text' do
    context 'for Values::URL' do
      let(:value)           { Ronin::Recon::Values::URL.new('https://www.example.com') }
      let(:expected_result) { "#{value.status} #{value}" }

      it 'must return the body text with status' do
        expect(subject.value_text(value)).to eq(expected_result)
      end
    end

    context 'for Values::Cert' do
      let(:value)           { Ronin::Recon::Values::Cert.new(cert) }
      let(:expected_result) { value.subject.to_h.map { |k,v| "#{k}: #{v}\n" }.join }

      it 'must return certificate subject' do
        expect(subject.value_text(value)).to eq(expected_result)
      end
    end

    context 'for other Values' do
      let(:value) { Ronin::Recon::Values::Domain.new('example.com') }

      it 'must return the body text' do
        expect(subject.value_text(value)).to eq(value.to_s)
      end
    end
  end

  describe '#<<' do
    let(:value) { Ronin::Recon::Values::Domain.new('example.com') }
    let(:label) { "#{subject.value_type(value)}\n#{subject.value_text(value)}" }
    let(:expected_result) do
      "digraph {\n\t#{value.to_s.inspect} [label=#{label.inspect}]\n"
    end

    it 'must writes a value to the GraphViz Dot output stream' do
      subject << value

      expect(io.string).to eq(expected_result)
    end
  end

  describe "#[]=" do
    let(:parent) { Ronin::Recon::Values::Domain.new('parent.com') }
    let(:value)  { Ronin::Recon::Values::Domain.new('value.com') }
    let(:expected_result) { "digraph {\n\t#{parent.to_s.inspect} -> #{value.to_s.inspect}\n" }

    it 'must append a value and its parent value to the GriphViz DOT output stream' do
      subject[value] = parent

      expect(io.string).to eq(expected_result)
    end
  end

  describe "#close" do
    let(:expected_result) { "digraph {\n}\n" }

    it 'must close the IO stream' do
      subject.close

      expect(io.string).to eq(expected_result)
    end
  end
end
