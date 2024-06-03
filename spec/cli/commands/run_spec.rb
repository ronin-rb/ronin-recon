require 'spec_helper'
require 'ronin/recon/cli/commands/run'
require 'ronin/recon/importer'
require_relative 'man_page_example'

describe Ronin::Recon::CLI::Commands::Run do
  include_examples "man_page"

  describe "#initialize" do
    it "must initialize #ignore to an empty Array" do
      expect(subject.ignore).to eq([])
    end
  end

  describe "options" do
    before { subject.option_parser.parse(argv) }

    context "when the '--output' option is given" do
      let(:path) { 'path/to/output.json' }
      let(:argv) { ['--output', path] }

      it "must set the :output option" do
        expect(subject.options[:output]).to eq(path)
      end

      it "must set the :output_format option using the path's file extension" do
        expect(subject.options[:output_format]).to be(Ronin::Core::OutputFormats::JSON)
      end

      context "but the '--output-format' has already been specified" do
        let(:path) { 'path/to/output.json' }
        let(:argv) { ['--output-format', 'ndjson', '--output', path] }

        it "must not override the already set :output_format" do
          expect(subject.options[:output_format]).to be(Ronin::Core::OutputFormats::NDJSON)
        end
      end
    end

    context "when the '--ignore' option is given" do
      let(:value1) { Ronin::Recon::Values::Host.new('staging.example.com') }
      let(:value2) { Ronin::Recon::Values::Host.new('dev.example.com') }
      let(:argv)   { ['--ignore', value1.to_s, '--ignore', value2.to_s] }

      it "must parse and append the values to #ignore" do
        expect(subject.ignore).to eq([value1, value2])
      end
    end
  end

  describe "#parse_value" do
    context "when given a valid value string" do
      let(:string) { 'www.example.com' }
      let(:value)  { Ronin::Recon::Values::Host.new(string) }

      it "must parse and return the value" do
        expect(subject.parse_value(string)).to eq(value)
      end
    end

    context "when given an invalid value string" do
      let(:string) { 'foo' }

      it "must print an error message and exit with -1" do
        expect(subject).to receive(:print_error).with("unrecognized recon value: #{string.inspect}")
        expect(subject).to receive(:print_error).with('value must be an IP address, CIDR IP-range, domain, sub-domain, wildcard hostname, or website base URL')
        expect(subject).to receive(:exit).with(-1)

        subject.parse_value(string)
      end
    end
  end

  describe "#import_value" do
    let(:value) { Ronin::Recon::Values::Host.new('www.example.com') }

    it "must call Ronin::Recon::Importer.import_value with the value" do
      expect(Ronin::Recon::Importer).to receive(:import_value).with(value)

      subject.import_value(value)
    end
  end

  describe "#import_connection" do
    let(:parent) { Ronin::Recon::Values::Domain.new('example.com') }
    let(:value)  { Ronin::Recon::Values::Host.new('www.example.com') }

    it "must call Ronin::Recon::Importer.import_connection with the value and parent value" do
      expect(Ronin::Recon::Importer).to receive(:import_connection).with(value,parent)

      subject.import_connection(value,parent)
    end
  end
end
