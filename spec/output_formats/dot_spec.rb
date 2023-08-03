require 'spec_helper'
require 'ronin/recon/output_formats/dot'

describe Ronin::Recon::OutputFormats::Dot do
  it "must inherit from Ronin::Core::OutputFormats::OutputFile" do
    expect(described_class).to be < Ronin::Core::OutputFormats::OutputFile
  end
end
