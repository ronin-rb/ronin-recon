require 'spec_helper'
require 'ronin/recon/cli/commands/run'
require 'ronin/recon/importer'
require_relative 'man_page_example'

describe Ronin::Recon::CLI::Commands::Run do
  include_examples "man_page"

  describe "#initialize" do
    it "must initialize #only_workers to an empty Set" do
      expect(subject.only_workers).to eq(Set.new)
    end

    it "must initialize #enable_workers to an empty Set" do
      expect(subject.enable_workers).to eq(Set.new)
    end

    it "must initialize #disable_workers to an empty Set" do
      expect(subject.disable_workers).to eq(Set.new)
    end

    it "must initialize #worker_files to an empty Set" do
      expect(subject.worker_files).to eq(Set.new)
    end

    it "must initialize #worker_params to an empty Hash" do
      expect(subject.worker_params).to eq({})
    end

    it "must initialize #worker_concurrency to an empty Hash" do
      expect(subject.worker_concurrency).to eq({})
    end

    it "must initialize #ignore to an empty Array" do
      expect(subject.ignore).to eq([])
    end
  end

  describe "options" do
    before { subject.option_parser.parse(argv) }

    context "when the '--worker WORKER' option is given" do
      let(:worker1) { 'dns/lookup' }
      let(:worker2) { 'dns/reverse_lookup' }
      let(:argv)    { ['--worker', worker1, '--worker', worker2] }

      it "must append the WORKER values to #only_workers" do
        expect(subject.only_workers).to eq(Set[worker1, worker2])
      end
    end

    context "when the '--enable WORKER' option is given" do
      let(:worker1) { 'dns/lookup' }
      let(:worker2) { 'dns/reverse_lookup' }
      let(:argv)    { ['--enable', worker1, '--enable', worker2] }

      it "must append the WORKER values to #enable_workers" do
        expect(subject.enable_workers).to eq(Set[worker1, worker2])
      end
    end

    context "when the '--disable WORKER' option is given" do
      let(:worker1) { 'dns/lookup' }
      let(:worker2) { 'dns/reverse_lookup' }
      let(:argv)    { ['--disable', worker1, '--disable', worker2] }

      it "must append the WORKER values to #disable_workers" do
        expect(subject.disable_workers).to eq(Set[worker1, worker2])
      end
    end

    context "when the '--worker-file FILE' option is given" do
      let(:file1) { 'path/to/worker1.rb' }
      let(:file2) { 'path/to/worker2.rb' }
      let(:argv) { ['--worker-file', file1, '--worker-file', file2] }

      it "must append the WORKER values to #worker_files" do
        expect(subject.worker_files).to eq(Set[file1, file2])
      end
    end

    context "when the '--param WORKER.NAME=VALUE' option is given" do
      let(:worker1) { 'test/worker1' }
      let(:name1)   { :foo }
      let(:value1)  { 'a' }
      let(:name2)   { :bar }
      let(:value2)  { 'b' }
      let(:worker2) { 'test/worker2' }
      let(:name3)   { :baz }
      let(:value3)  { 'x' }
      let(:name4)   { :qux }
      let(:value4)  { 'y' }
      let(:argv) do
        [
          '--param', "#{worker1}.#{name1}=#{value1}",
          '--param', "#{worker1}.#{name2}=#{value2}",
          '--param', "#{worker2}.#{name3}=#{value3}",
          '--param', "#{worker2}.#{name4}=#{value4}"
        ]
      end

      it "must parse and populate #worker_params with the params grouped by worker ID" do
        expect(subject.worker_params).to eq(
          {
            worker1 => {
              name1 => value1,
              name2 => value2
            },
            worker2 => {
              name3 => value3,
              name4 => value4
            }
          }
        )
      end
    end

    context "when the '--concurrency WORKER=NUM' option is given" do
      let(:worker1)      { 'test/worker1' }
      let(:concurrency1) { 42 }
      let(:worker2)      { 'test/worker2' }
      let(:concurrency2) { 10 }
      let(:argv) do
        [
          '--concurrency', "#{worker1}=#{concurrency1}",
          '--concurrency', "#{worker2}=#{concurrency2}"
        ]
      end

      it "must parse and populate #worker_concurrency grouped by worker ID" do
        expect(subject.worker_concurrency).to eq(
          {
            worker1 => concurrency1,
            worker2 => concurrency2
          }
        )
      end
    end

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

  let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }

  describe "#load_config" do
    context "when the '--config-file FILE' option has not been given" do
      before { subject.load_config }

      it "must set #config using Ronin::Recon::Config.default" do
        expect(subject.config).to eq(Ronin::Recon::Config.default)
      end
    end

    context "when the '--config-file FILE' option has been given" do
      let(:config_file) { File.join(fixtures_dir,'config.yml') }

      before do
        subject.options[:config_file] = config_file

        subject.load_config
      end

      it "must set #config using Ronin::Recon::Config.load" do
        expect(subject.config).to eq(Ronin::Recon::Config.load(config_file))
      end
    end

    context "when the '--worker WORKER' option has been given" do
      let(:worker1) { 'dns/lookup' }
      let(:worker2) { 'dns/reverse_lookup' }

      before do
        subject.only_workers << worker1 << worker2

        subject.load_config
      end

      it "must override #config.workers with the workers" do
        expect(subject.config.workers.ids).to eq(Set[worker1, worker2])
      end
    end

    context "when the '--enable WORKER' option has been given" do
      let(:worker1) { 'test/worker1' }
      let(:worker2) { 'test/worker2' }

      before do
        subject.enable_workers << worker1 << worker2

        subject.load_config
      end

      it "must add the workers to #config.workers" do
        expect(subject.config.workers.ids).to include(worker1)
        expect(subject.config.workers.ids).to include(worker2)
      end
    end

    context "when the '--disable WORKER' option has been given" do
      let(:worker1) { 'dns/lookup' }
      let(:worker2) { 'dns/reverse_lookup' }

      before do
        subject.disable_workers << worker1 << worker2

        subject.load_config
      end

      it "must remove the workers from #config.workers" do
        expect(subject.config.workers.ids).to_not include(worker1)
        expect(subject.config.workers.ids).to_not include(worker2)
      end
    end

    context "when the '--params WORKER.NAME=VALUE' option has been given" do
      let(:worker1) { 'test/worker1' }
      let(:name1)   { :foo }
      let(:value1)  { 'a' }
      let(:name2)   { :bar }
      let(:value2)  { 'b' }
      let(:worker2) { 'test/worker2' }
      let(:name3)   { :baz }
      let(:value3)  { 'x' }
      let(:name4)   { :qux }
      let(:value4)  { 'y' }

      before do
        subject.worker_params[worker1][name1] = value1
        subject.worker_params[worker1][name2] = value2
        subject.worker_params[worker2][name3] = value3
        subject.worker_params[worker2][name4] = value4

        subject.load_config
      end

      it "must populate #config.params with the params" do
        expect(subject.config.params[worker1][name1]).to eq(value1)
        expect(subject.config.params[worker1][name2]).to eq(value2)
        expect(subject.config.params[worker2][name3]).to eq(value3)
        expect(subject.config.params[worker2][name4]).to eq(value4)
      end
    end

    context "when the '--concurrency WORKER=VALUE' option has been given" do
      let(:worker1)      { 'test/worker1' }
      let(:concurrency1) { 42 }
      let(:worker2)      { 'test/worker2' }
      let(:concurrency2) { 10 }

      before do
        subject.worker_concurrency[worker1] = concurrency1
        subject.worker_concurrency[worker2] = concurrency2

        subject.load_config
      end

      it "must populate #config.concurrency with the concurrencies" do
        expect(subject.config.concurrency[worker1]).to eq(concurrency1)
        expect(subject.config.concurrency[worker2]).to eq(concurrency2)
      end
    end
  end

  describe "#load_workers" do
    it "must load the workers in #config.workers and set #workers" do
      subject.load_config
      subject.load_workers

      expect(subject.workers).to eq(
        Ronin::Recon::Workers.load(subject.config.workers)
      )
    end

    context "when the '--worker-file FILE' option has been given" do
      let(:file) { File.join(fixtures_dir,'test_worker.rb') }

      before do
        subject.worker_files << file

        subject.load_config
        subject.load_workers
      end

      it "must load the worker from the given FILE" do
        expect(subject.workers).to include(Ronin::Recon::TestWorker)
      end
    end

    context "when the '--intensity LEVEL' option has been given" do
      let(:intensity) { :passive }

      before do
        subject.options[:intensity] = intensity

        subject.load_config
        subject.load_workers
      end

      it "must filter #workers by the intensity level" do
        expect(subject.workers.map(&:intensity)).to all(eq(intensity))
      end
    end

    context "when one of the enabled workers cannot be found" do
      let(:worker) { 'does/not/exist' }
      before { subject.enable_workers << worker }

      it "must print an error and exit with 1" do
        expect(subject).to receive(:print_error).with("could not find file for #{worker.inspect}")
        expect(subject).to receive(:exit).with(1)

        subject.load_config
        subject.load_workers
      end
    end

    context "when one of the enabled worker files does not exist" do
      let(:worker_file) { 'does/not/exist' }
      before { subject.worker_files << worker_file }

      it "must print an error and exit with 1" do
        expect(subject).to receive(:print_error).with("no such file or directory: #{File.expand_path(worker_file).inspect}")
        expect(subject).to receive(:exit).with(1)

        subject.load_config
        subject.load_workers
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
