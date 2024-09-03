require 'spec_helper'
require 'ronin/recon/cli/commands/config/enable'

require_relative '../man_page_example'

require 'tempfile'

describe Ronin::Recon::CLI::Commands::Config::Enable do
  include_examples "man_page"

  describe "#run" do
    let(:tempfile)    { Tempfile.new(['ronin-recon-config-','.yml']) }
    let(:config_file) { tempfile.path }

    let(:worker) { 'test/worker1' }

    before do
      config = Ronin::Recon::Config.new
      config.workers.add(worker)
      config.save(config_file)
    end

    before do
      subject.options[:config_file] = config_file
    end

    it "must enable the worker in the config file" do
      subject.run(worker)

      config = Ronin::Recon::Config.load(config_file)
      expect(config.workers).to include(worker)
    end
  end
end
