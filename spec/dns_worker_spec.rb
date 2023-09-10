require 'spec_helper'
require 'ronin/recon/dns_worker'

describe Ronin::Recon::DNSWorker do
  it "must include Mixins::DNS" do
    expect(described_class).to include(Ronin::Recon::Mixins::DNS)
  end

  it "must set intensity to :passive" do
    expect(described_class.intensity).to be(:passive)
  end
end
