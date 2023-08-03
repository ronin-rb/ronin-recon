require 'spec_helper'
require 'ronin/recon/output_formats/dir'

describe Ronin::Recon::OutputFormats::Dir do
  it "must inherit from Ronin::Core::OutputFormats::OutputDir" do
    expect(described_class).to be < Ronin::Core::OutputFormats::OutputDir
  end
end
