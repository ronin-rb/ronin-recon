require 'spec_helper'
require 'ronin/recon/cli/commands/config/disable'

require_relative '../man_page_example'

require 'tempfile'

describe Ronin::Recon::CLI::Commands::Config::Disable do
  include_examples "man_page"

  describe "#run" do
    let(:tempfile)    { Tempfile.new(['ronin-recon-config-','.yml']) }
    let(:config_file) { tempfile.path }

    let(:worker) { 'dns/reverse_lookup' }

    before do
      config = Ronin::Recon::Config.new
      config.save(config_file)
    end

    before do
      subject.options[:config_file] = config_file
    end

    it "must disable the worker in the config file" do
      subject.run(worker)

      config = Ronin::Recon::Config.load(config_file)
      expect(config.workers).to_not include(worker)
    end
  end
end
