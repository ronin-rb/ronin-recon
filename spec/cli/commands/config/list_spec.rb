require 'spec_helper'
require 'ronin/recon/cli/commands/config/list'

require_relative '../man_page_example'

require 'tempfile'

describe Ronin::Recon::CLI::Commands::Config::List do
  include_examples "man_page"

  describe "#run" do
    let(:tempfile)    { Tempfile.new(['ronin-recon-config-','.yml']) }
    let(:config_file) { tempfile.path }

    before do
      subject.options[:config_file] = config_file
    end

    context "when the config file is empty" do
      before do
        config = Ronin::Recon::Config.new
        config.save(config_file)
      end

      it "must print the default workers" do
        expect {
          subject.run
        }.to output(
          [
            "Workers:",
            *Ronin::Recon::Config::Workers::DEFAULT.map { |worker|
              " * #{worker}"
            },
            ''
          ].join($/)
        ).to_stdout
      end
    end

    context "when the config file has workers enabled or disalbed" do
      let(:enabled_worker1)  { 'test/worker1' }
      let(:enabled_worker2)  { 'test/worker2' }
      let(:enabled_worker3)  { 'test/worker3' }
      let(:disabled_worker1) { 'dns/reverse_lookup' }
      let(:disabled_worker2) { 'dns/subdomain_enum' }

      before do
        config = Ronin::Recon::Config.new
        config.workers.add(enabled_worker1)
        config.workers.add(enabled_worker2)
        config.workers.add(enabled_worker3)
        config.workers.delete(disabled_worker1)
        config.workers.delete(disabled_worker2)
        config.save(config_file)
      end

      it "must print the enabled workers in addition to the default workers that were not disabled" do
        config = Ronin::Recon::Config.load(config_file)

        expect {
          subject.run
        }.to output(
          [
            "Workers:",
            *config.workers.map { |worker|
              " * #{worker}"
            },
            ''
          ].join($/)
        ).to_stdout
      end
    end

    context "when the config file has concurrency values set" do
      let(:worker1) { 'test/worker1' }
      let(:worker2) { 'test/worker2' }
      let(:worker3) { 'test/worker3' }

      let(:concurrency1) { 2 }
      let(:concurrency2) { 10 }
      let(:concurrency3) { 42 }

      before do
        config = Ronin::Recon::Config.new(
          concurrency: {
            worker1 => concurrency1,
            worker2 => concurrency2,
            worker3 => concurrency3
          }
        )
        config.save(config_file)
      end

      it "must print the concurrency values for the workers" do
        config = Ronin::Recon::Config.load(config_file)

        expect {
          subject.run
        }.to output(
          [
            "Workers:",
            *config.workers.map { |worker|
              " * #{worker}"
            },
            '',
            'Concurrency:',
            " * #{worker1}=#{concurrency1}",
            " * #{worker2}=#{concurrency2}",
            " * #{worker3}=#{concurrency3}",
            ''
          ].join($/)
        ).to_stdout
      end
    end

    context "when the config file has param values set" do
      let(:worker1) { 'test/worker1' }
      let(:worker2) { 'test/worker2' }

      let(:param_name1)  { :foo }
      let(:param_value1) { true }
      let(:param_name2)  { :bar }
      let(:param_value2) { 42 }
      let(:param_name3)  { :baz }
      let(:param_value3) { 'xyz' }

      before do
        config = Ronin::Recon::Config.new(
          params: {
            worker1 => {
              param_name1 => param_value1,
              param_name2 => param_value2
            },
            worker2 => {
              param_name3 => param_value3
            }
          }
        )
        config.save(config_file)
      end

      it "must print the concurrency values for the workers" do
        config = Ronin::Recon::Config.load(config_file)

        expect {
          subject.run
        }.to output(
          [
            "Workers:",
            *config.workers.map { |worker|
              " * #{worker}"
            },
            '',
            'Params:',
            " * #{worker1}",
            "   * #{param_name1}=#{param_value1}",
            "   * #{param_name2}=#{param_value2}",
            " * #{worker2}",
            "   * #{param_name3}=#{param_value3}",
            ''
          ].join($/)
        ).to_stdout
      end
    end
  end
end
