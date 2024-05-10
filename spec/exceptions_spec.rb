require 'spec_helper'
require 'ronin/recon/exceptions'

describe Ronin::Recon::UnknownValue do
  it { expect(described_class).to be < Ronin::Recon::Exception }
end
