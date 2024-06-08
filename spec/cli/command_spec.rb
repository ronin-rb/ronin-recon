require 'spec_helper'
require 'ronin/recon/cli/command'

describe Ronin::Recon::CLI::Command do
  it { expect(described_class).to be < Ronin::Core::CLI::Command }

  it "must set .man_dir" do
    expect(described_class.man_dir).to eq(File.join(Ronin::Recon::ROOT,'man'))
  end

  it "must set .bug_report_rul" do
    expect(described_class.bug_report_url).to eq('https://github.com/ronin-rb/ronin-recon/issues/new')
  end
end
