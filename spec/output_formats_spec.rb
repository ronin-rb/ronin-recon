require 'spec_helper'
require 'ronin/recon/output_formats'

describe Ronin::Recon::OutputFormats do
  describe "formats" do
    subject { described_class.formats }

    describe ":txt" do
      it "must equal Ronin::Core::OutputFormats::TXT" do
        expect(subject[:txt]).to be(Ronin::Core::OutputFormats::TXT)
      end
    end

    describe ":csv" do
      it "must equal Ronin::Core::OutputFormats::CSV" do
        expect(subject[:csv]).to be(Ronin::Core::OutputFormats::CSV)
      end
    end

    describe ":json" do
      it "must equal Ronin::Core::OutputFormats::JSON" do
        expect(subject[:json]).to be(Ronin::Core::OutputFormats::JSON)
      end
    end

    describe ":ndjson" do
      it "must equal Ronin::Core::OutputFormats::NDJSON" do
        expect(subject[:ndjson]).to be(Ronin::Core::OutputFormats::NDJSON)
      end
    end

    describe ":dir" do
      it "must equal Ronin::Recon::OutputFormats::Dir" do
        expect(subject[:dir]).to be(Ronin::Recon::OutputFormats::Dir)
      end
    end

    describe ":dot" do
      it "must equal Ronin::Recon::OutputFormats::Dot" do
        expect(subject[:dot]).to be(Ronin::Recon::OutputFormats::Dot)
      end
    end
  end

  describe "file_exts" do
    subject { described_class.file_exts }

    describe "'.txt'" do
      it "must equal Ronin::Core::OutputFormats::TXT" do
        expect(subject['.txt']).to be(Ronin::Core::OutputFormats::TXT)
      end
    end

    describe "'.csv'" do
      it "must equal Ronin::Core::OutputFormats::CSV" do
        expect(subject['.csv']).to be(Ronin::Core::OutputFormats::CSV)
      end
    end

    describe "'.json'" do
      it "must equal Ronin::Core::OutputFormats::JSON" do
        expect(subject['.json']).to be(Ronin::Core::OutputFormats::JSON)
      end
    end

    describe "'.ndjson'" do
      it "must equal Ronin::Core::OutputFormats::NDJSON" do
        expect(subject['.ndjson']).to be(Ronin::Core::OutputFormats::NDJSON)
      end
    end

    describe "''" do
      it "must equal Ronin::Recon::OutputFormats::Dir" do
        expect(subject['']).to be(Ronin::Recon::OutputFormats::Dir)
      end
    end

    describe "'.dot'" do
      it "must equal Ronin::Recon::OutputFormats::Dot" do
        expect(subject['.dot']).to be(Ronin::Recon::OutputFormats::Dot)
      end
    end
  end
end
