require 'spec_helper'
require 'ronin/recon/exceptions'

describe Ronin::Recon::UnknownValue do
  it { expect(described_class).to be < Ronin::Recon::Exception }
end

describe Ronin::Recon::InvalidConfig do
  it { expect(described_class).to be < Ronin::Recon::Exception }
end

describe Ronin::Recon::InvalidConfigFile do
  it { expect(described_class).to be < Ronin::Recon::InvalidConfig }
end
