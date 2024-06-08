require 'spec_helper'
require 'ronin/recon/cli/commands/irb'
require_relative 'man_page_example'

describe Ronin::Recon::CLI::Commands::Irb do
  include_examples "man_page"

  describe "#run" do
    it "must call CLI::RubyShell.start" do
      expect(Ronin::Recon::CLI::RubyShell).to receive(:start)

      subject.run
    end
  end
end
