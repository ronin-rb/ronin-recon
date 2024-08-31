require 'spec_helper'
require 'ronin/recon/builtin/web/screenshot'

require 'webmock/rspec'

describe Ronin::Recon::Web::Screenshot do
  let(:dir) { Dir.mktmpdir('test-ronin-recon-web-screenshot') }

  subject { described_class.new(params: { output_dir: dir }) }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  describe "#process" do
    let(:url)  { Ronin::Recon::Values::URL.new('https://www.example.com') }
    let(:path) { File.join(dir,"www.example.com","index.png") }

    before do
      stub_request(:get, 'https://www.example.com')
        .to_return(status: 200, body: "")
    end

    it "must visit a website and take a screenshot of it" do
      subject.process(url)

      expect(File.exist?(path)).to be(true)
    end
  end

  describe "#path_for" do
    context "when url ends with '/'" do
      let(:url) { 'https://www.example.com/' }
      let(:expected_path) { File.join(dir,'www.example.com','index.png') }

      it "must add 'index' to the returned path" do
        expect(subject.path_for(url)).to eq(expected_path)
      end
    end

    context "when url does not ends with '/'" do
      let(:url) { 'https://www.example.com/foo/bar.php' }
      let(:expected_path) { File.join(dir, 'www.example.com','foo','bar.php.png') }

      it "must return path" do
        expect(subject.path_for(url)).to eq(expected_path)
      end
    end
  end
end
