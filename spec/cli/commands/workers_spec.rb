require 'spec_helper'
require 'ronin/recon/cli/commands/workers'

describe Ronin::Recon::CLI::Commands::Workers do
  describe "#run" do
    it "must list all worker IDs" do
      expect {
        subject.run
      }.to output(
        Ronin::Recon.list_files.map { |id|
          "  #{id}"
        }.join($/) + $/
      ).to_stdout
    end

    context "when given a directory argument" do
      let(:dir) { 'dns' }

      it "must only list workers that exist within that directory" do
        expect {
          subject.run(dir)
        }.to output(
          Ronin::Recon.list_files.select { |id|
            id.start_with?("#{dir}/")
          }.map { |id|
            "  #{id}"
          }.join($/) + $/
        ).to_stdout
      end
    end
  end
end
