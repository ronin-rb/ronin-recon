require 'spec_helper'
require 'ronin/recon/web_worker'

describe Ronin::Recon::WebWorker do
  it "must include Mixins::HTTP" do
    expect(described_class).to include(Ronin::Recon::Mixins::HTTP)
  end
end
