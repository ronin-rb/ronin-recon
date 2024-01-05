require 'spec_helper'
require 'ronin/recon/cli/ruby_shell'

describe Ronin::Recon::CLI::RubyShell do
  describe "#initialize" do
    it "must default #name to 'ronin-recon'" do
      expect(subject.name).to eq('ronin-recon')
    end

    it "must default context: to Ronin::Recon" do
      expect(subject.context).to be_a(Object)
      expect(subject.context).to be_kind_of(Ronin::Recon)
    end
  end
end
