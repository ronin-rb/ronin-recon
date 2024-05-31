require 'spec_helper'
require 'ronin/recon/engine'

describe Ronin::Recon::Engine do
  let(:values) do
    [
      Ronin::Recon::Values::IP.new('1.2.3.4'),
      Ronin::Recon::Values::IPRange.new('1.2.3.4/24'),
      Ronin::Recon::Values::Domain.new('example.com'),
      Ronin::Recon::Values::Host.new('www.example.com'),
      Ronin::Recon::Values::Wildcard.new('*.example.com')
    ]
  end

  subject { described_class.new(values) }

  describe "#initialize" do
    it "must initialize #scope to a Ronin::Recon::Scope using the given values" do
      expect(subject.scope).to be_kind_of(Ronin::Recon::Scope)
      expect(subject.scope.values).to eq(values)
    end

    it "must initialize the ignored values in #scope to an empty Array" do
      expect(subject.scope.ignore).to eq([])
    end

    it "must default #workers to Ronin::Recon::WorkerSet.default" do
      expect(subject.workers).to eq(Ronin::Recon::WorkerSet.default)
    end

    it "must initialize #value_status to an empty Ronin::Recon::ValueStatus" do
      expect(subject.value_status).to be_kind_of(Ronin::Recon::ValueStatus)
      expect(subject.value_status).to be_empty
    end

    it "must initialize #graph to an empty Ronin::Recon::Graph" do
      expect(subject.graph).to be_kind_of(Ronin::Recon::Graph)
      expect(subject.graph).to be_empty
    end

    it "must default #max_depth to nil" do
      expect(subject.max_depth).to be(nil)
    end

    it "must default #logger to Console.logger" do
      expect(subject.logger).to eq(Console.logger)
    end

    context "when given the ignore: keyword argument" do
      let(:ignore) do
        [
          Ronin::Recon::Values::Host.new('dev.example.com'),
          Ronin::Recon::Values::Host.new('staging.example.com')
        ]
      end

      subject { described_class.new(values, ignore: ignore) }

      it "must initialize the #ignore of the #scope to the given ignore: keyword argument value" do
        expect(subject.scope.ignore).to eq(ignore)
      end
    end

    context "when given the max_depth: keyword argument" do
      let(:max_depth) { 3 }

      subject { described_class.new(values, max_depth: max_depth) }

      it "must set #max_depth" do
        expect(subject.max_depth).to eq(max_depth)
      end
    end

    context "when given the workers: keyword argument" do
      let(:workers) do
        Ronin::Recon::WorkerSet.load(
          %w[
            dns/lookup
            dns/mailservers
            dns/nameservers
            dns/subdomain_enum
            dns/suffix_enum
            dns/srv_enum
          ]
        )
      end

      subject { described_class.new(values, workers: workers) }

      it "must set #workers" do
        expect(subject.workers).to eq(workers)
      end
    end

    context "when given the logger: keyword argument" do
      let(:logger) { Console::Logger.new(STDOUT) }

      subject { described_class.new(values, logger: logger) }

      it "must set #logger" do
        expect(subject.logger).to be(logger)
      end
    end

    context "when given a block" do
      it "must yield the newly created #{described_class}" do
        expect { |b|
          described_class.new(values,&b)
        }.to yield_with_args(described_class)
      end
    end
  end

  describe "#values" do
    it "must return #graph.nodes" do
      expect(subject.values).to be(subject.graph.nodes)
    end
  end
end
