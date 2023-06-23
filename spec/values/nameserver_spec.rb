require 'spec_helper'
require 'ronin/recon/values/nameserver'

describe Ronin::Recon::Values::Nameserver do
  let(:name) { 'a.iana-servers.net.' }

  subject { described_class.new(name) }

  describe "#as_json" do
    it "must return a Hash containing the type: and name: attributes" do
      expect(subject.as_json).to eq({type: :nameserver, name: name})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :nameserver" do
      expect(subject.value_type).to be(:nameserver)
    end
  end
end
