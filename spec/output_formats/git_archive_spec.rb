require 'spec_helper'
require 'ronin/recon/output_formats/git_archive'
require 'ronin/recon/values/url'
require 'ronin/recon/values/domain'
require 'tmpdir'

describe Ronin::Recon::OutputFormats::GitArchive do
  subject { described_class.new(path) }

  let(:path) { Dir.mktmpdir('ronin-recon-output-git-archive') }

  describe "#<<" do
    context "for Values::URL" do
      let(:value)         { Ronin::Recon::Values::URL.new('https://www.example.com/foo.html') }
      let(:expected_path) { File.join(path,value.path) }

      it "must create a new file with webpage" do
        subject << value

        expect(File.exist?(expected_path)).to be(true)
      end
    end

    context "for other values" do
      let(:value) { Ronin::Recon::Values::Domain.new('example.com') }

      it "must not create any files" do
        subject << value

        expect(Dir.glob("#{path}/*")).to be_empty
      end
    end
  end
end
