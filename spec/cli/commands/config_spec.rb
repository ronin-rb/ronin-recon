require 'spec_helper'
require 'ronin/recon/cli/commands/config'

require_relative 'man_page_example'

describe Ronin::Recon::CLI::Commands::Config do
  include_examples "man_page"
end
