require 'spec_helper'
require 'ronin/recon/worker_tasks'
require 'ronin/recon/worker'
require 'ronin/recon/message/value'

describe Ronin::Recon::WorkerTasks do
  subject { described_class.new(worker, output_queue: Async::Queue.new) }

  module TestWorkerTasks
    class TestWorker < Ronin::Recon::Worker
      def process(value)
        yield Ronin::Recon::Values::Domain.new('example.com')
      end
    end

    class TestWorkerWithConcurrency < Ronin::Recon::Worker
      def process(value); end
    end
  end

  describe "#initialize" do
    let(:worker) { TestWorkerTasks::TestWorker.new }

    it "must initialize #worker and #concurrency" do
      expect(subject.worker).to be(worker)
      expect(subject.concurrency).to be(worker.class.concurrency)
      expect(subject.input_queue).to be_kind_of(Async::Queue)
      expect(subject.output_queue).to be_kind_of(Async::Queue)
      expect(subject.logger).to be(Console.logger)
    end
  end

  describe "#enqueue_mesg" do
    context "for Message::SHUTDOWN" do
      let(:mesg_value) { Ronin::Recon::Message::SHUTDOWN }
      let(:worker)     { TestWorkerTasks::TestWorkerWithConcurrency.new }

      before do
        TestWorkerTasks::TestWorkerWithConcurrency.concurrency(2)
      end

      it "must enqueue Message::Shutdown into #input_queue 2 times" do
        Async { subject.enqueue_mesg(mesg_value) }

        expect(subject.instance_variable_get(:@input_queue).items).to all(be_kind_of(Ronin::Recon::Message::Shutdown))
        expect(subject.instance_variable_get(:@input_queue).items.size).to be(2)
      end
    end

    context "for other Message's" do
      let(:mesg_value) { Ronin::Recon::Message::Value }
      let(:worker)     { TestWorkerTasks::TestWorker.new }

      it "must enqueue Message into #input_queue" do
        Async { subject.enqueue_mesg(mesg_value) }

        expect(subject.instance_variable_get(:@input_queue).items).to eq([mesg_value])
      end
    end
  end

  describe "#run" do
    let(:worker)        { TestWorkerTasks::TestWorker.new }
    let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
    let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

    before do
      TestWorkerTasks::TestWorker.concurrency(1)
    end

    context "if Message::SHUTDOWN is next in the queue" do
      it "must breaks the loop and not process other messages" do
        Async do
          subject.enqueue_mesg(shutdown_mesg)
          subject.enqueue_mesg(value_mesg)
          subject.run
        end

        expect(subject.instance_variable_get(:@input_queue).items.size).to eq(1)
      end
    end

    context "if other Message is next in the queue" do
      it "must enqueue Message::JobStarted, yielded value and MessageJob::Completed" do
        Async do
          subject.enqueue_mesg(value_mesg)
          subject.enqueue_mesg(shutdown_mesg)
          subject.run
        end

        expect(subject.instance_variable_get(:@output_queue).items.size).to eq(4)
        expect(subject.instance_variable_get(:@output_queue).items[0]).to be_kind_of(Ronin::Recon::Message::JobStarted)
        expect(subject.instance_variable_get(:@output_queue).items[1]).to be_kind_of(Ronin::Recon::Message::Value)
        expect(subject.instance_variable_get(:@output_queue).items[2]).to be_kind_of(Ronin::Recon::Message::JobCompleted)
      end
    end
  end

  describe "#start" do
    let(:worker)        { TestWorkerTasks::TestWorkerWithConcurrency.new }
    let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
    let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

    before do
      TestWorkerTasks::TestWorkerWithConcurrency.concurrency(1)
    end

    it "must add tast to #tasks" do
      Async do
        subject.enqueue_mesg(shutdown_mesg)
        subject.start
      end

      expect(subject.instance_variable_get(:@tasks).size).to eq(1)
    end
  end

  describe "#started!" do
    let(:worker) { TestWorkerTasks::TestWorker.new }

    it "must enqueue Message::WorkerStarted instance into #output_queue" do
      Async { subject.started! }

      expect(subject.instance_variable_get(:@output_queue).items.size).to eq(1)
      expect(subject.instance_variable_get(:@output_queue).items[0]).to be_kind_of(Ronin::Recon::Message::WorkerStarted)
    end
  end

  describe "#stopped!" do
    let(:worker) { TestWorkerTasks::TestWorker.new }

    it "must enqueue Message::WorkerStopped instance into #output_queue" do
      Async { subject.stopped! }

      expect(subject.instance_variable_get(:@output_queue).items.size).to eq(1)
      expect(subject.instance_variable_get(:@output_queue).items[0]).to be_kind_of(Ronin::Recon::Message::WorkerStopped)
    end
  end

  describe "#enqueue" do
    let(:worker) { TestWorkerTasks::TestWorker.new }
    let(:mesg)   { Ronin::Recon::Message::JobFailed }

    it "must enqueue Message into #output_queue" do
      Async { subject.send(:enqueue, mesg) }

      expect(subject.instance_variable_get(:@output_queue).items.size).to eq(1)
      expect(subject.instance_variable_get(:@output_queue).items[0]).to be(Ronin::Recon::Message::JobFailed)
    end
  end
end
