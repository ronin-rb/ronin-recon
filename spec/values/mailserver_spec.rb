require 'spec_helper'
require 'ronin/recon/values/mailserver'

describe Ronin::Recon::Values::Mailserver do
  let(:name) { 'aspmx.l.google.com' }

  subject { described_class.new(name) }

  describe "#as_json" do
    it "must return a Hash containing the type: and name: attributes" do
      expect(subject.as_json).to eq({type: :mailserver, name: name})
    end
  end

  describe ".value_type" do
    subject { described_class }

    it "must return :mailserver " do
      expect(subject.value_type).to be(:mailserver)
    end
  end
end
