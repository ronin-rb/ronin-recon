require 'spec_helper'
require 'ronin/recon/cli/printing'
require 'ronin/recon/cli/command'

describe Ronin::Recon::CLI::Printing do
  module TestPrinting
    class TestCommand < Ronin::Recon::CLI::Command
      include Ronin::Recon::CLI::Printing
    end
  end

  let(:command_class) { TestPrinting::TestCommand }
  subject { command_class.new }

  let(:fixtures_dir) { File.join(__dir__,'..','fixtures') }

  describe "#print_value" do
    let(:stdout) { StringIO.new }

    subject { command_class.new(stdout: stdout) }

    let(:value) { Ronin::Recon::Values::Host.new('www.example.com') }

    context "when STDOUT is a TTY" do
      before { expect(stdout).to receive(:tty?).and_return(true) }

      it "must log 'Found new \#{format_value(value)}'" do
        expect(subject).to receive(:log_info).with("Found new #{subject.format_value(value)}")

        subject.print_value(value)
      end

      context "when given a parent value" do
        let(:parent) { Ronin::Recon::Values::Domain.new('example.com') }

        it "must log 'Found new \#{format_value(value)} for \#{format_value(parent)}'" do
          expect(subject).to receive(:log_info).with("Found new #{subject.format_value(value)} for #{subject.format_value(parent)}")

          subject.print_value(value,parent)
        end
      end
    end

    context "when STDOUT is not a TTY" do
      before { allow(stdout).to receive(:tty?).and_return(false) }

      it "must print the value to STDOUT" do
        expect(subject).to receive(:puts).with(value)

        subject.print_value(value)
      end
    end
  end
end
