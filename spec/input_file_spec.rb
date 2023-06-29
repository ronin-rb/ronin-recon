require 'spec_helper'
require 'ronin/recon/input_file'

describe Ronin::Recon::InputFile do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }
  let(:path)         { File.join(fixtures_dir,'input_file.txt') }

  subject { described_class.new(path) }

  describe "#initialize" do
    it "must set #path" do
      expect(subject.path).to eq(path)
    end
  end

  describe ".open" do
    subject { described_class.open(path) }

    it "must create a new InputFile with the given path" do
      expect(subject).to be_kind_of(described_class)
      expect(subject.path).to eq(path)
    end
  end

  describe "#each" do
    context "when given a block" do
      it "must parse each line of the input file and yield each value" do
        expect { |b|
          subject.each(&b)
        }.to yield_successive_args(
          Ronin::Recon::Values::IP.new('1.2.3.4'),
          Ronin::Recon::Values::IPRange.new('1.2.3.4/24'),
          Ronin::Recon::Values::Domain.new('example.com'),
          Ronin::Recon::Values::Host.new('www.example.com'),
          Ronin::Recon::Values::Wildcard.new('*.example.com'),
          Ronin::Recon::Values::Website.parse('https://example.com')
        )
      end
    end

    context "when no block is given" do
      it "must an Enumerator object for the method" do
        expect(subject.each.to_a).to eq(
          [
            Ronin::Recon::Values::IP.new('1.2.3.4'),
            Ronin::Recon::Values::IPRange.new('1.2.3.4/24'),
            Ronin::Recon::Values::Domain.new('example.com'),
            Ronin::Recon::Values::Host.new('www.example.com'),
            Ronin::Recon::Values::Wildcard.new('*.example.com'),
            Ronin::Recon::Values::Website.parse('https://example.com')
          ]
        )
      end
    end
  end
end
