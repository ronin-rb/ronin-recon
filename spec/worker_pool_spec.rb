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

      def process(value)
      end
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
    context "when given Message::SHUTDOWN" do
      context "when the Worker class has a concurrency of 1" do
        let(:mesg_value) { Ronin::Recon::Message::SHUTDOWN }
        let(:worker)     { TestWorkerPool::TestWorker.new }

        it "must enqueue Message::SHUTDOWN into #input_queue once" do
          Async { subject.enqueue_mesg(mesg_value) }

          subject.input_queue.close

          expect(subject.input_queue.size).to be(1)
          expect { |b|
            subject.input_queue.each(&b)
          }.to yield_successive_args(Ronin::Recon::Message::SHUTDOWN)
        end
      end

      context "when the Worker class has a concurrency greater than 1" do
        let(:mesg_value) { Ronin::Recon::Message::SHUTDOWN }
        let(:worker)     { TestWorkerPool::TestWorkerWithConcurrency.new }

        it "must enqueue Message::SHUTDOWN into #input_queue the same number of times as the Worker class'es concurrency" do
          Async { subject.enqueue_mesg(mesg_value) }

          subject.input_queue.close

          expect(subject.input_queue.size).to be(worker.class.concurrency)
          expect { |b|
            subject.input_queue.each(&b)
          }.to yield_successive_args(
            *[Ronin::Recon::Message::SHUTDOWN] * worker.class.concurrency
          )
        end
      end
    end

    context "when given Message::Value" do
      let(:mesg_value) { Ronin::Recon::Message::Value }
      let(:worker)     { TestWorkerPool::TestWorker.new }

      it "must enqueue Message into #input_queue once" do
        Async { subject.enqueue_mesg(mesg_value) }

        subject.input_queue.close

        expect { |b|
          subject.input_queue.each(&b)
        }.to yield_successive_args(mesg_value)
      end

      context "and when the Worker class has a concurrency greater than 1" do
        let(:worker) { TestWorkerPool::TestWorkerWithConcurrency.new }

        it "must still enqueue Message::Value into #input_queue once" do
          Async { subject.enqueue_mesg(mesg_value) }

          subject.input_queue.close

          expect(subject.input_queue.size).to be(1)
          expect { |b|
            subject.input_queue.each(&b)
          }.to yield_successive_args(mesg_value)
        end
      end
    end
  end

  describe "#run" do
    let(:worker)        { TestWorkerPool::TestWorker.new }
    let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
    let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

    context "if Message::SHUTDOWN is the next message in the queue" do
      it "must break the loop and not process other messages" do
        Async do
          subject.enqueue_mesg(shutdown_mesg)
          subject.enqueue_mesg(value_mesg)
          subject.run
        end

        subject.input_queue.close

        expect(subject.input_queue.size).to eq(1)
        expect { |b|
          subject.input_queue.each(&b)
        }.to yield_successive_args(value_mesg)
      end
    end

    context "if a Message::Value is the next message in the queue" do
      it "must enqueue Message::JobStarted, a Message::Value for the yielded value from the worker, and finally a Message::JobCompleted message" do
        Async do
          subject.enqueue_mesg(value_mesg)
          subject.enqueue_mesg(shutdown_mesg)
          subject.run
        end

        subject.output_queue.close

        expect(subject.output_queue.size).to eq(4)
        expect { |b|
          subject.output_queue.each(&b)
        }.to yield_successive_args(
          Ronin::Recon::Message::JobStarted,
          Ronin::Recon::Message::Value,
          Ronin::Recon::Message::JobCompleted,
          Ronin::Recon::Message::WorkerStopped
        )
      end
    end
  end

  describe "#start" do
    context "when the Worker class has a concurrency of 1" do
      let(:worker)        { TestWorkerPool::TestWorker.new }
      let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
      let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

      it "must add one Async::Task to #tasks" do
        Async do
          subject.enqueue_mesg(shutdown_mesg)
          subject.start
        end

        expect(subject.instance_variable_get(:@tasks).size).to eq(1)
      end
    end

    context "when the Worker class has a concurrency greater than 1" do
      let(:worker)        { TestWorkerPool::TestWorkerWithConcurrency.new }
      let(:shutdown_mesg) { Ronin::Recon::Message::SHUTDOWN }
      let(:value_mesg)    { Ronin::Recon::Message::Value.new("value") }

      it "must add the same number of Async::Tasks to #tasks as the Worker class'es concurrency" do
        Async do
          subject.enqueue_mesg(shutdown_mesg)
          subject.start
        end

        expect(subject.instance_variable_get(:@tasks).size).to eq(
          worker.class.concurrency
        )
      end
    end
  end

  describe "#started!" do
    let(:worker) { TestWorkerPool::TestWorker.new }

    it "must enqueue Message::WorkerStarted instance into #output_queue" do
      Async { subject.started! }

      subject.output_queue.close

      expect(subject.output_queue.size).to eq(1)
      expect { |b|
        subject.output_queue.each(&b)
      }.to yield_successive_args(Ronin::Recon::Message::WorkerStarted)
    end
  end

  describe "#stopped!" do
    let(:worker) { TestWorkerPool::TestWorker.new }

    it "must enqueue Message::WorkerStopped instance into #output_queue" do
      Async { subject.stopped! }

      subject.output_queue.close

      expect(subject.output_queue.size).to eq(1)
      expect { |b|
        subject.output_queue.each(&b)
      }.to yield_successive_args(Ronin::Recon::Message::WorkerStopped)
    end
  end

  describe "#enqueue" do
    let(:worker) { TestWorkerPool::TestWorker.new }
    let(:mesg)   { Ronin::Recon::Message::JobFailed }

    it "must enqueue the message into #output_queue" do
      Async { subject.send(:enqueue, mesg) }

      subject.output_queue.close

      expect(subject.output_queue.size).to eq(1)
      expect { |b|
        subject.output_queue.each(&b)
      }.to yield_successive_args(Ronin::Recon::Message::JobFailed)
    end
  end
end
