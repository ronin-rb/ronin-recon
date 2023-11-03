require 'spec_helper'
require 'ronin/recon/output_formats/svg'

require 'stringio'

describe Ronin::Recon::OutputFormats::SVG do
  it "must inherit from Ronin::Core::OutputFormats::GraphvizFormat" do
    expect(described_class).to be < Ronin::Recon::OutputFormats::GraphvizFormat
  end

  let(:io) { StringIO.new }

  subject { described_class.new(io) }

  describe "#format" do
    it "must return :svg" do
      expect(subject.format).to eq(:svg)
    end
  end
end
