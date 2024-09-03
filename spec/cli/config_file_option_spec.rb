require 'spec_helper'
require 'ronin/recon/cli/config_file_option'
require 'ronin/recon/cli/command'

describe Ronin::Recon::CLI::ConfigFileOption do
  module TestConfigFileOption
    class TestCommand < Ronin::Recon::CLI::Command

      include Ronin::Recon::CLI::ConfigFileOption

    end
  end

  let(:test_command) { TestConfigFileOption::TestCommand }
  subject { test_command.new }

  describe ".included" do
    subject { test_command }

    it "must define a '-C, --config-file' option" do
      expect(subject.options[:config_file]).to_not be(nil)
      expect(subject.options[:config_file].short).to eq('-C')
      expect(subject.options[:config_file].value).to_not be(nil)
      expect(subject.options[:config_file].value.type).to be(String)
      expect(subject.options[:config_file].desc).to eq('Loads the configuration file')
    end
  end

  describe "#load_config" do
    let(:fixtures) { File.join(__dir__,'..','fixtures') }

    context "when the '-C, --config-file' option is not given" do
      before { subject.load_config }

      it "must set @config to `Config.default`" do
        expect(subject.config).to eq(Ronin::Recon::Config.default)
      end
    end

    context "when the '-C, --config-file' option is given" do
      context "and the config file exists and is valid" do
        let(:config_file) { File.join(fixtures,'config.yml') }

        before do
          subject.options[:config_file] = config_file

          subject.load_config
        end

        it "must load the config file and set @config" do
          expect(subject.config).to eq(
            Ronin::Recon::Config.load(config_file)
          )
        end
      end

      context "but the config file does not exist" do
        let(:config_file) { 'does/not/exist.yml' }

        before do
          subject.options[:config_file] = config_file
        end

        it "must print an error and exit with -1" do
          expect(subject).to receive(:print_error).with("no such file or directory: #{config_file}")

          expect {
            subject.load_config
          }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(-1)
          end
        end
      end

      context "but the config file is invalid" do
        let(:fixtures_dir) { File.join(__dir__,'..','fixtures') }
        let(:config_file)  { File.join(fixtures_dir,'config','does_not_contain_a_hash.yml') }
        let(:yaml)         { YAML.load_file(config_file) }

        before do
          subject.options[:config_file] = config_file
        end

        it "must print an error and exit with -2" do
          expect(subject).to receive(:print_error).with("invalid config file (#{config_file.inspect}): must contain a Hash: #{yaml.inspect}")

          expect {
            subject.load_config
          }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq(-2)
          end
        end
      end
    end
  end
end
