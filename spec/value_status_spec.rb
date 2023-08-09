require 'spec_helper'
require 'ronin/recon/value_status'
require 'ronin/recon/worker'

describe Ronin::Recon::ValueStatus do
  module TestValueStatus
    class TestWorker < Ronin::Recon::Worker; end
    class TestWorker2 < Ronin::Recon::Worker; end
  end

  let(:worker_class)  { TestValueStatus::TestWorker }
  let(:worker_class2) { TestValueStatus::TestWorker2 }

  describe "#initialize" do
    it "must initialize #values" do
      expect(subject.values).to eq({})
    end
  end

  describe "#value_enqueued" do
    let(:value) { Ronin::Recon::Values::IP.new('192.160.1.1') }

    context "when #values has value key" do
      before do
        subject.value_enqueued(worker_class2, value)
      end

      it "must add new key worker_class with value :enqueued" do
        subject.value_enqueued(worker_class, value)
        expect(subject.values[value].size).to eq(2)
        expect(subject.values[value][worker_class]).to eq(:enqueued)
      end
    end

    context "when #values has no value key" do
      it "must create an empty hash and add workerk_class key with value :enqueued" do
        subject.value_enqueued(worker_class, value)
        expect(subject.values[value].size).to eq(1)
        expect(subject.values[value][worker_class]).to eq(:enqueued)
      end
    end
  end

  describe "#job_started" do
    let(:value) { Ronin::Recon::Values::IP.new('192.168.1.1') }

    context "when #values has value key" do
      before do
        subject.job_started(worker_class2, value)
      end

      it "must add new key worker_class with value :enqueued" do
        subject.job_started(worker_class, value)
        expect(subject.values[value].size).to eq(2)
        expect(subject.values[value][worker_class]).to eq(:working)
      end
    end

    context "when #values has no value key" do
      it "must create an empty hash and add workerk_class key with value :working" do
        subject.job_started(worker_class, value)
        expect(subject.values[value].size).to eq(1)
        expect(subject.values[value][worker_class]).to eq(:working)
      end
    end
  end

  describe "#job_completed" do
    let(:value) { Ronin::Recon::Values::IP.new('162.168.1.1') }

    context "when #values is empty" do
      it "must retun nil" do
        expect(subject.job_completed(worker_class, value)).to be(nil)
      end
    end

    context "when #values is not empty" do
      context "and contains different workers" do
        before do
          subject.job_started(worker_class, value)
          subject.job_started(worker_class2, value)
        end

        it "must delete worker_class" do
          subject.job_completed(worker_class, value)
          expect(subject.values[value]).to eq({ worker_class2 => :working })
        end
      end

      context "but contains last worker" do
        before do
          subject.job_started(worker_class, value)
        end

        it "must delete worker_class from value and value from #values" do
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
      let(:value) { Ronin::Recon::Values::IP.new('192.168.1.1') }

      it "must return false" do
        subject.job_started(worker_class, value)
        expect(subject.empty?).to be(false)
      end
    end
  end
end
