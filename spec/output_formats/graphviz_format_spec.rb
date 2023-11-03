require 'spec_helper'
require 'ronin/recon/output_formats/graphviz_format'
require 'ronin/recon/values/host'
require 'ronin/recon/values/domain'

require 'stringio'

describe Ronin::Recon::OutputFormats::GraphvizFormat do
  it "must inherit from Ronin::Core::OutputFormats::OutputFile" do
    expect(described_class).to be < Ronin::Core::OutputFormats::OutputFile
  end

  it "must include Ronin::Core::OutputFormats::GraphFormat" do
    expect(described_class).to include(Ronin::Recon::OutputFormats::GraphFormat)
  end

  module TestGraphvizFormat
    class SVG < Ronin::Recon::OutputFormats::GraphvizFormat

      def format
        :svg
      end

    end
  end

  let(:output_format_class) { TestGraphvizFormat::SVG }
  let(:io) { StringIO.new }

  subject { output_format_class.new(io) }

  let(:value)  { Ronin::Recon::Values::Host.new('www.example.com') }
  let(:parent) { Ronin::Recon::Values::Domain.new('example.com') }

  describe "#<<" do
    it "must call #<< on #dot_output with the given value" do
      expect(subject.dot_output).to receive(:<<).with(value)

      subject << value
    end
  end

  describe "#[]=" do
    it "must call #[]= on #dot_output with the given value and parent value" do
      expect(subject.dot_output).to receive(:[]=).with(value,parent)

      subject[value] = parent
    end
  end

  describe "#close" do
    before do
      subject << parent
      subject << value

      subject[value] = parent

      subject.close
    end

    it "must create a .dot output file" do
      expect(File.file?(subject.dot_file.path)).to be(true)
      expect(File.read(subject.dot_file.path)).to eq(
        <<~DOT
          digraph {
          \t"#{parent}" [label="Domain\\n#{parent}"]
          \t"#{value}" [label="Host\\n#{value}"]
          \t"#{parent}" -> "#{value}"
          }
        DOT
      )
    end

    it "must also generate the GraphViz output file from the .dot file" do
      expect(io.string).to start_with(%{<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n})
      expect(io.string).to end_with(%{</svg>\n})
    end
  end
end
