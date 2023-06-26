require 'spec_helper'
require 'ronin/recon/dns_worker'

describe Ronin::Recon::DNSWorker do
  it "must include Mixins::DNS" do
    expect(described_class).to include(Ronin::Recon::Mixins::DNS)
  end
end
