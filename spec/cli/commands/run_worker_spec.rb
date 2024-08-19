require 'spec_helper'
require 'ronin/recon/cli/commands/run_worker'

require 'fixtures/test_worker'

describe Ronin::Recon::CLI::Commands::RunWorker do
  describe "#run" do
    let(:name)  { 'test_worker' }
    let(:value) { 'example.com' }

    context "when given a worker name" do
      it "must load the worker and run it with the given value" do
        expect {
          subject.run(name,value)
        }.to output(
          <<~OUTPUT
            test1.#{value}
            test2.#{value}
          OUTPUT
        ).to_stdout
      end
    end

    context "when the '--file FILE' option instead of a worker name argument" do
      let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }
      let(:path)         { File.join(fixtures_dir,'test_worker.rb') }

      before { subject.option_parser.parse(['--file', path]) }

      it "must load the worker from the file and run it with the given value" do
        expect {
          subject.run(value)
        }.to output(
          <<~OUTPUT
            test1.#{value}
            test2.#{value}
          OUTPUT
        ).to_stdout
      end
    end

    context "when a '--param NAME=VALUE' option is given" do
      let(:prefix) { 'foo' }

      before { subject.option_parser.parse(['--param', "prefix=#{prefix}"]) }

      it "must parse the params and initialize the worker with them" do
        expect {
          subject.run(name,value)
        }.to output(
          <<~OUTPUT
            #{prefix}1.#{value}
            #{prefix}2.#{value}
          OUTPUT
        ).to_stdout
      end
    end

    context "when given an unknown input value" do
      let(:value) { 'bad' }

      it "must print an error message and exit with -1" do
        expect {
          subject.run(name,value)
        }.to output(
          <<~ERROR
            #{subject.command_name}: unrecognized recon value: #{value.inspect}
            #{subject.command_name}: must be a domain value
          ERROR
        ).to_stderr.and(raise_error(SystemExit) { |error|
          expect(error.status).to eq(-1)
        })
      end
    end

    context "when given an unacceptable input value" do
      let(:value) { '192.168.1.1' }

      it "must print an error message and exit with 1" do
        expect {
          subject.run(name,value)
        }.to output(
          <<~ERROR
            #{subject.command_name}: worker #{name.inspect} does not accept IP address values
            #{subject.command_name}: must be a domain value
          ERROR
        ).to_stderr.and(raise_error(SystemExit) { |error|
          expect(error.status).to eq(1)
        })
      end
    end
  end
end
