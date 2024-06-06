require 'spec_helper'
require 'ronin/recon/cli/worker_command'

describe Ronin::Recon::CLI::WorkerCommand do
  module TestWorkerCommand
    class TestCommand < Ronin::Recon::CLI::WorkerCommand
    end
  end

  let(:command_class) { TestWorkerCommand::TestCommand }
  subject { command_class.new }

  let(:fixtures_dir) { File.join(__dir__,'..','fixtures') }

  describe "#run" do
    context "when given a WORKER argument" do
      let(:worker_id)    { 'dns/lookup' }
      let(:worker_class) { Ronin::Recon::DNS::Lookup }

      it "must load the WORKER and set #worker_class" do
        subject.run(worker_id)

        expect(subject.worker_class).to be(worker_class)
      end
    end

    context "when given the '--file FILE' option" do
      let(:argv) { ['--file', worker_file] }

      before { subject.option_parser.parse(argv) }

      let(:worker_file)  { File.join(fixtures_dir,'test_worker.rb') }
      let(:worker_class) { Ronin::Recon::TestWorker }

      it "must load the worker from the FILE and set #worker_class" do
        subject.run

        expect(subject.worker_class).to be(worker_class)
      end
    end

    context "when neither a WORKER argument nor a `--file` option was given" do
      it "must print an error message and exit with -1" do
        expect(subject).to receive(:print_error).with("must specify --file or a NAME")
        expect(subject).to receive(:exit).with(-1)

        subject.run
      end
    end
  end

  describe "#load_worker" do
    let(:worker_id)    { 'dns/lookup' }
    let(:worker_class) { Ronin::Recon::DNS::Lookup }

    it "must load and return the worker class" do
      expect(subject.load_worker(worker_id)).to be(worker_class)
    end

    it "must also set #worker_class" do
      subject.load_worker(worker_id)

      expect(subject.worker_class).to be(worker_class)
    end

    context "when the worker cannot be found" do
      let(:worker_id) { 'does/not/exist' }

      it "must print an error message and exit with an error code" do
        expect(subject).to receive(:print_error).with("could not find file for #{worker_id.inspect}")
        expect(subject).to receive(:exit).with(1)

        subject.load_worker(worker_id)
      end
    end

    context "when the worker file raises an exception" do
      let(:worker_id) { 'bad/worker' }
      let(:exception) { RuntimeError.new("error") }

      before do
        expect(Ronin::Recon).to receive(:load_class).with(worker_id).and_raise(exception)
      end

      it "must print the exception and exit with -1" do
        expect(subject).to receive(:print_exception).with(exception)
        expect(subject).to receive(:print_error).with("an unhandled exception occurred while loading recon worker #{worker_id}")
        expect(subject).to receive(:exit).with(-1)

        subject.load_worker(worker_id)
      end
    end
  end

  describe "#load_worker_from" do
    let(:worker_file)  { File.join(fixtures_dir,'test_worker.rb') }
    let(:worker_class) { Ronin::Recon::TestWorker }

    let(:absolute_worker_file) { File.expand_path(worker_file) }

    it "must load the file and return the worker class" do
      expect(subject.load_worker_from(worker_file)).to be(worker_class)
    end

    it "must also set #worker_class" do
      subject.load_worker_from(worker_file)

      expect(subject.worker_class).to be(worker_class)
    end

    context "when the worker cannot be found" do
      let(:worker_file) { File.join(fixtures_dir,'does','not','exist.rb') }

      it "must print an error message and exit with an error code" do
        expect(subject).to receive(:print_error).with("no such file or directory: #{absolute_worker_file.inspect}")
        expect(subject).to receive(:exit).with(1)

        subject.load_worker_from(worker_file)
      end
    end

    context "when the worker file raises an exception" do
      let(:exception) { RuntimeError.new("error") }

      it "must print the exception and exit with -1" do
        expect(Ronin::Recon).to receive(:require).with(absolute_worker_file).and_raise(exception)

        expect(subject).to receive(:print_exception).with(exception)
        expect(subject).to receive(:print_error).with("an unhandled exception occurred while loading recon worker from file #{worker_file}")
        expect(subject).to receive(:exit).with(-1)

        subject.load_worker_from(worker_file)
      end
    end
  end
end
