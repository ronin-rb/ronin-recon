require 'spec_helper'
require 'ronin/recon/worker_set'
require 'ronin/recon/builtin'

describe Ronin::Recon::WorkerSet do
  let(:worker_ids) do
    %w[
      dns/lookup
      dns/mailservers
      dns/nameservers
      dns/subdomain_enum
      dns/suffix_enum
      dns/srv_enum
      net/ip_range_enum
      net/port_scan
      net/service_id
      ssl/cert_grab
      ssl/cert_enum
      web/spider
    ]
  end

  let(:workers) do
    [
      Ronin::Recon::DNS::Lookup,
      Ronin::Recon::DNS::Mailservers,
      Ronin::Recon::DNS::Nameservers,
      Ronin::Recon::DNS::SubdomainEnum,
      Ronin::Recon::DNS::SuffixEnum,
      Ronin::Recon::DNS::SRVEnum,
      Ronin::Recon::Net::IPRangeEnum,
      Ronin::Recon::Net::PortScan,
      Ronin::Recon::Net::ServiceID,
      Ronin::Recon::SSL::CertGrab,
      Ronin::Recon::SSL::CertEnum,
      Ronin::Recon::Web::Spider
    ]
  end

  subject { described_class.new(workers) }

  describe "#initialize" do
    context "when given an Array of workers" do
      it "must initialize #workers to a Set of the given workers" do
        expect(subject.workers).to be_kind_of(Set)
        expect(subject.workers.to_a).to eq(workers)
      end
    end

    context "when no arguments are given" do
      subject { described_class.new }

      it "must initialize #workers to an empty Set" do
        expect(subject.workers).to eq(Set.new)
      end
    end
  end

  describe ".load" do
    subject { described_class }

    it "must load the worker classes and return a new #{described_class}" do
      worker_set = subject.load(worker_ids)

      expect(worker_set).to be_kind_of(described_class)
      expect(worker_set.workers.to_a).to eq(workers)
    end
  end

  describe ".[]" do
    subject { described_class }

    it "must load the worker classes and return a new #{described_class}" do
      worker_set = subject[*worker_ids]

      expect(worker_set).to be_kind_of(described_class)
      expect(worker_set.workers.to_a).to eq(workers)
    end
  end

  describe ".all" do
    subject { described_class }

    it "must load all workers and return a #{described_class}" do
      worker_set = subject.all

      expect(worker_set).to be_kind_of(described_class)
      expect(worker_set.workers.map(&:id)).to eq(
        Ronin::Recon.list_files
      )
    end
  end

  describe ".default" do
    subject { described_class }

    it "must load the default set of workers and return a #{described_class}" do
      worker_set = subject.default

      expect(worker_set).to be_kind_of(described_class)
      expect(worker_set.workers.map(&:id)).to eq(described_class::DEFAULT_SET)
    end
  end

  describe ".category" do
    subject { described_class }

    let(:category) { 'dns' }

    it "must load the workers within the cateogyr and return a #{described_class}" do
      worker_set = subject.category(category)

      expect(worker_set).to be_kind_of(described_class)
      expect(worker_set.workers.map(&:id)).to all(start_with(category))
    end
  end

  describe "#each" do
    context "when given a block" do
      it "must enumerate over the worker classes in #workers" do
        expect { |b|
          subject.each(&b)
        }.to yield_successive_args(*workers)
      end
    end

    context "when no block is given" do
      it "must return an Enumerator for the workers classes in #workers" do
        expect(subject.each).to be_kind_of(Enumerator)
        expect(subject.each.to_a).to eq(workers)
      end
    end
  end

  describe "#+" do
    let(:workers) do
      [
        Ronin::Recon::DNS::Lookup,
        Ronin::Recon::DNS::Mailservers,
        Ronin::Recon::DNS::Nameservers,
        Ronin::Recon::DNS::SubdomainEnum,
        Ronin::Recon::DNS::SuffixEnum,
        Ronin::Recon::DNS::SRVEnum,
        Ronin::Recon::Net::IPRangeEnum,
        Ronin::Recon::Net::PortScan,
        Ronin::Recon::Net::ServiceID,
        Ronin::Recon::SSL::CertGrab,
        Ronin::Recon::SSL::CertEnum
      ]
    end

    subject { described_class.new(workers) }

    let(:other_workers) do
      [
        Ronin::Recon::Net::IPRangeEnum,
        Ronin::Recon::Net::PortScan,
        Ronin::Recon::Net::ServiceID,
        Ronin::Recon::SSL::CertGrab,
        Ronin::Recon::SSL::CertEnum,
        Ronin::Recon::Web::Spider
      ]
    end

    let(:other_worker_set) { described_class.new(other_workers) }

    context "when given another #{described_class}" do
      it "must combine the workers in the other worker set with the worker set" do
        worker_set = subject + other_worker_set

        expect(worker_set).to be_kind_of(described_class)
        expect(worker_set.workers).to eq(
          (workers + other_workers).to_set
        )
      end
    end

    context "when given an Array of workers" do
      let(:other_worker_set) { other_workers }

      it "must combine the workers in the other worker set with the worker set" do
        worker_set = subject + other_worker_set

        expect(worker_set).to be_kind_of(described_class)
        expect(worker_set.workers).to eq(
          (workers + other_workers).to_set
        )
      end
    end
  end

  describe "#<<" do
    let(:worker) { Ronin::Recon::Web::DirEnum }

    before { subject << worker }

    it "must add the worker class to the worker set" do
      expect(subject.workers).to include(worker)
    end
  end

  describe "#load" do
    let(:worker_id) { 'web/dir_enum' }
    let(:worker)    { Ronin::Recon::Web::DirEnum }

    before { subject.load(worker_id) }

    it "must load and add the worker class to the worker set" do
      expect(subject.workers).to include(worker)
    end
  end

  describe "#load_file" do
    let(:fixtures_dir) { File.join(__dir__,'fixtures') }
    let(:path)         { File.join(fixtures_dir,'test_worker.rb') }

    before { subject.load_file(path) }

    it "must load the file and add the worker to the worker set" do
      expect(defined?(Ronin::Recon::TestWorker)).to be_truthy
      expect(subject.workers).to include(Ronin::Recon::TestWorker)
    end
  end

  describe "#delete" do
    context "when the worker class does exist in the worker set" do
      let(:worker) { Ronin::Recon::DNS::SubdomainEnum }

      it "must retruen self" do
        expect(subject.delete(worker)).to be(subject)
      end

      it "must remove the worker class from the worker set" do
        subject.delete(worker)

        expect(subject.workers).to_not include(worker)
      end
    end

    context "when the worker class does not exist in the worker set" do
      let(:worker) { Ronin::Recon::Web::DirEnum }

      it "must return nil" do
        expect(subject.delete(worker)).to be(nil)
      end
    end
  end

  describe "#remove" do
    context "when the worker ID exists within the worker set" do
      let(:worker)    { Ronin::Recon::DNS::SubdomainEnum }
      let(:worker_id) { 'dns/subdomain_enum' }

      it "must retruen self" do
        expect(subject.remove(worker_id)).to be(subject)
      end

      it "must remove the worker class from the worker set" do
        subject.remove(worker_id)

        expect(subject.workers).to_not include(worker)
      end
    end

    context "when the worker ID does not exist in the worker set" do
      let(:worker)    { Ronin::Recon::Web::DirEnum }
      let(:worker_id) { 'web/dir_enum' }

      it "must return nil" do
        expect(subject.remove(worker_id)).to be(nil)
      end
    end
  end

  describe "#intensity" do
    let(:intensity) { :active }

    it "must filter the workers by intensity and return a new #{described_class}" do
      worker_set = subject.intensity(intensity)

      expect(worker_set).to be_kind_of(described_class)
      expect(worker_set.workers.map(&:intensity)).to all(eq(:passive).or(eq(:active)))
    end
  end

  describe "#to_set" do
    it "must return a Set of the workers" do
      expect(subject.to_set).to be_kind_of(Set)
      expect(subject.to_set.to_a).to eq(workers)
    end
  end
end
