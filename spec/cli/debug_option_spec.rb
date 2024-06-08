require 'spec_helper'
require 'ronin/recon/cli/debug_option'
require 'ronin/recon/cli/command'

describe Ronin::Recon::CLI::DebugOption do
  module TestDebugOption
    class TestCommand < Ronin::Recon::CLI::Command
      include Ronin::Recon::CLI::DebugOption
    end
  end

  let(:command_class) { TestDebugOption::TestCommand }
  subject { command_class.new }

  describe "options" do
    before { subject.option_parser.parse(argv) }

    describe "when the '--debug' option is given" do
      let(:argv) { %w[--debug] }

      it "must set Console.logger.level to Console::Logger::DEBUG" do
        expect(Console.logger.level).to be(Console::Logger::DEBUG)
      end

      after { Console.logger.level = Console::Logger::INFO }
    end
  end
end
