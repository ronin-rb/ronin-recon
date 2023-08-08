require 'spec_helper'
require 'ronin/recon/value_status'
require 'ronin/recon/worker'

describe Ronin::Recon::ValueStatus do
  module TestWorkers
    class TestWorker < Ronin::Recon::Worker
    end
  end

  describe "#initialize" do
    it "must initialize #values" do
      expect(subject.values).to eq({})
    end
  end

  describe "#value_enqueued" do
    let(:worker_class)  { TestWorkers::TestWorker }
    let(:value)         { Ronin::Recon::Values::IP.new('10.12.13.14') }
    let(:expected_hash) { { foo: :bar, worker_class => :enqueued } }

    context "when #values has value key" do
      it "must add new key worker_class with value :enqueued" do
        subject.values[value] = { foo: :bar }
        expect(subject.value_enqueued(worker_class, value)).to eq(:enqueued)
        expect(subject.values[value]).to eq(expected_hash)
      end
    end

    context "when #values has no value key" do
      it "must create an empty hash and add workerk_class key with value :enqueued" do
        subject.value_enqueued(worker_class, value)
        expect(subject.values[value][worker_class]).to eq(:enqueued)
      end
    end
  end

  describe "#job_started" do
    let(:worker_class)  { TestWorkers::TestWorker }
    let(:value)         { Ronin::Recon::Values::IP.new('10.12.13.14') }
    let(:expected_hash) { { foo: :bar, worker_class => :working } }

    context "when #values has value key" do
      it "must add new key worker_class with value :enqueued" do
        subject.values[value] = { foo: :bar }
        expect(subject.job_started(worker_class, value)).to eq(:working)
        expect(subject.values[value]).to eq(expected_hash)
      end
    end

    context "when #values has no value key" do
      it "must create an empty hash and add workerk_class key with value :working" do
        subject.job_started(worker_class, value)
        expect(subject.values[value][worker_class]).to eq(:working)
      end
    end
  end

  describe "#job_completed" do
    let(:worker_class)  { TestWorkers::TestWorker }
    let(:value)         { Ronin::Recon::Values::IP.new('10.12.13.14') }

    context "when #values is empty" do
      it "must retun nil" do
        expect(subject.job_completed(worker_class, value)).to be(nil)
      end
    end

    context "when #values is not empty" do
      context "and contains different workers" do
        module TestWorkers
          class TestWorker2 < Ronin::Recon::Worker
          end
        end
        let(:worker_class2) { TestWorkers::TestWorker2 }

        it "must delete worker_class" do
          subject.job_started(worker_class, value)
          subject.job_started(worker_class2, value)
          subject.job_completed(worker_class, value)
          expect(subject.values[value]).to eq({ worker_class2 => :working })
        end
      end

      context "but contains last worker" do
        it "must delete worker_class from value and value from #values" do
          subject.job_started(worker_class, value)
          subject.job_completed(worker_class, value)
          expect(subject.values).to eq({})
        end
      end
    end
  end

  describe "#empty?" do
    context "when #values is empty" do
      it "must return true" do
        expect(subject.empty?).to be(true)
      end
    end

    context "when #values is not empty" do
      let(:worker_class)  { TestWorkers::TestWorker }
      let(:value)         { Ronin::Recon::Values::IP.new('10.12.13.14') }

      it "must return false" do
        subject.job_started(worker_class, value)
        expect(subject.empty?).to be(false)
      end
    end
  end
end
