require 'spec_helper'
require 'ronin/recon/cli/commands/config/set'

require_relative '../man_page_example'

require 'tempfile'

describe Ronin::Recon::CLI::Commands::Config::Set do
  include_examples "man_page"

  describe "#run" do
    let(:tempfile)    { Tempfile.new(['ronin-recon-config-','.yml']) }
    let(:config_file) { tempfile.path }

    let(:worker) { 'test/worker1' }

    context "when the --concurrency option is given" do
      let(:concurrency) { 10 }

      before do
        config = Ronin::Recon::Config.new
        config.save(config_file)
      end

      before do
        subject.option_parser.parse(
          [
            '--config-file', config_file,
            '--concurrency', "#{worker}=#{concurrency}"
          ]
        )
      end

      it "must print the concurrency value for the worker to stdout" do
        subject.run

        config = Ronin::Recon::Config.load(config_file)
        expect(config.concurrency[worker]).to eq(concurrency)
      end
    end

    context "when the --param option is given" do
      let(:param_name)  { :foo }
      let(:param_value) { 'bar' }

      before do
        config = Ronin::Recon::Config.new
        config.save(config_file)
      end

      before do
        subject.option_parser.parse(
          [
            '--config-file', config_file,
            '--param', "#{worker}.#{param_name}=#{param_value}"
          ]
        )
      end

      it "must print the param valeu for the worker to stdout" do
        subject.run

        config = Ronin::Recon::Config.load(config_file)
        expect(config.params[worker][param_name]).to eq(param_value)
      end
    end

    context "when neither the --concurrency or --param options are given" do
      it "must print an error and exit with 1" do
        expect(subject).to receive(:print_error).with("--concurrency or --param options must be given")

        expect {
          subject.run
        }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(-1)
        end
      end
    end
  end
end
