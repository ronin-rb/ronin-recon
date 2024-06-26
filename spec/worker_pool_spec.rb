require 'spec_helper'
require 'ronin/recon/worker_pool'
require 'ronin/recon/worker'
require 'ronin/recon/message/value'

describe Ronin::Recon::WorkerPool do
  subject { described_class.new(worker, output_queue: Async::Queue.new) }

  module TestWorkerPool
    class TestWorker < Ronin::Recon::Worker
      def process(value)
        yield Ronin::Recon::Values::Domain.new('example.com')
      end
    end

    class TestWorkerWithConcurrency < Ronin::Recon::Worker
      concurrency 2
      def process(value); end
    end
  end

  describe "#initialize" do
    let(:worker) { TestWorkerPool::TestWorker.new }

    it "must initialize #worker worker object" do
      expect(subject.worker).to be(worker)
    end

    it "must initialize #concurrency to worker object concurrency" do
      expect(subject.concurrency).to be(worker.class.concurrency)
    end

    it "must initialize #input_queue to a new Async::Queue" do
      expect(subject.input_queue).to be_kind_of(Async::Queue)
    end

    it "must initialize #output_queue to a new Async::Queue" do
      expect(subject.output_queue).to be_kind_of(Async::Queue)
    end

    it "must initialize #logger to a Console.logger" do
      expect(subject.logger).to be(Console.logger)
    end
  end

  describe "#enqueue_mesg" do
    context "for Message::SHUTDOWN" do
      let(:mesg_value) { Ronin::Recon::Message::SHUTDOWN }
      let(:worker)     { TestWorkerPool::TestWorkerWithConcurrency.new }

      it "must enqueue Message::Shutdown into #input_queue 2 times" do
        Async { subject.enqueue_mesg(mesg_value) }

        expect(subject.input_queue.items).to all(be_kind_of(Ronin::Recon::Message::Shutdown))
        expect(subject.input_queue.items.size).to be(2)
      end
    end

    context "for other Message's" do
      let(:mesg_value) { Ronin::Recon::Message::Value }
      let(:worker)     { TestWorkerPool::TestWorker.new }

      it "must enqueue Message into #input_queue" do
        Async { subject.enqueue_mesg(mesg_value) }

        expect(subject.input_queue.items).to eq([mesg_value])
      end
    end
  end

  describe "#run" do
    let(:worker)        { TestWorkerPool::TestWorker.new }
    let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
    let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

    context "if Message::SHUTDOWN is next in the queue" do
      it "must breaks the loop and not process other messages" do
        Async do
          subject.enqueue_mesg(shutdown_mesg)
          subject.enqueue_mesg(value_mesg)
          subject.run
        end

        expect(subject.input_queue.items.size).to eq(1)
      end
    end

    context "if other Message is next in the queue" do
      it "must enqueue Message::JobStarted, yielded value and MessageJob::Completed" do
        Async do
          subject.enqueue_mesg(value_mesg)
          subject.enqueue_mesg(shutdown_mesg)
          subject.run
        end

        expect(subject.output_queue.items.size).to eq(4)
        expect(subject.output_queue.items[0]).to be_kind_of(Ronin::Recon::Message::JobStarted)
        expect(subject.output_queue.items[1]).to be_kind_of(Ronin::Recon::Message::Value)
        expect(subject.output_queue.items[2]).to be_kind_of(Ronin::Recon::Message::JobCompleted)
      end
    end
  end

  describe "#start" do
    let(:worker)        { TestWorkerPool::TestWorkerWithConcurrency.new }
    let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
    let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

    it "must add tasks to #tasks" do
      Async do
        subject.enqueue_mesg(shutdown_mesg)
        subject.start
      end

      expect(subject.instance_variable_get(:@tasks).size).to eq(2)
    end
  end

  describe "#started!" do
    let(:worker) { TestWorkerPool::TestWorker.new }

    it "must enqueue Message::WorkerStarted instance into #output_queue" do
      Async { subject.started! }

      expect(subject.output_queue.items.size).to eq(1)
      expect(subject.output_queue.items[0]).to be_kind_of(Ronin::Recon::Message::WorkerStarted)
    end
  end

  describe "#stopped!" do
    let(:worker) { TestWorkerPool::TestWorker.new }

    it "must enqueue Message::WorkerStopped instance into #output_queue" do
      Async { subject.stopped! }

      expect(subject.output_queue.items.size).to eq(1)
      expect(subject.output_queue.items[0]).to be_kind_of(Ronin::Recon::Message::WorkerStopped)
    end
  end

  describe "#enqueue" do
    let(:worker) { TestWorkerPool::TestWorker.new }
    let(:mesg)   { Ronin::Recon::Message::JobFailed }

    it "must enqueue Message into #output_queue" do
      Async { subject.send(:enqueue, mesg) }

      expect(subject.output_queue.items.size).to eq(1)
      expect(subject.output_queue.items[0]).to be(Ronin::Recon::Message::JobFailed)
    end
  end
end
