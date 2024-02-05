require 'spec_helper'
require 'ronin/recon/engine'

describe Ronin::Recon::Engine do
  subject     { described_class.new([value], workers: []) }
  let(:value) { Ronin::Recon::Values::Domain.new("example.com") }

  module TestEngine
    class TestWorker < Ronin::Recon::Worker
      accepts Domain

      def process(value); end
    end
  end

  let(:worker) { TestEngine::TestWorker.new }

  describe "#initialize" do
    it "must initialzie #scope, #value_status, #graph and #max_depth" do
      expect(subject.scope.values).to eql(Ronin::Recon::Scope.new([value]).values)
      expect(subject.value_status.values).to eq({})
      expect(subject.max_depth).to be(nil)
      expect(subject.graph.nodes).to eq(Set.new)
    end
  end

  describe "#add_worker" do
    it "must add worker class to #worker_classes and WorkerTasks instance to #worker_tasks" do
      Async { subject.add_worker(TestEngine::TestWorker) }

      expect(subject.instance_variable_get(:@worker_classes)).to eq({ Ronin::Recon::Values::Domain => [TestEngine::TestWorker] })
      expect(subject.instance_variable_get(:@worker_tasks)[Ronin::Recon::Values::Domain][0]).to be_kind_of(Ronin::Recon::WorkerTasks)
    end
  end

  describe "#on" do
    let(:block) { proc { |foo| puts "foo" } }

    context "for :value event" do
      it "must pass block to #value_callbacks" do
        subject.on(:value, &block)

        expect(subject.instance_variable_get(:@value_callbacks)).to eq([block])
      end
    end

    context "for :connection event" do
      it "must pass block to #connection_callbacks" do
        subject.on(:connection, &block)

        expect(subject.instance_variable_get(:@connection_callbacks)).to eq([block])
      end
    end

    context "for :job_started event" do
      it "must pass block to #job_started_callbacks" do
        subject.on(:job_started, &block)

        expect(subject.instance_variable_get(:@job_started_callbacks)).to eq([block])
      end
    end

    context "for :job_completed event" do
      it "must pass block to #job_completed_callbacks" do
        subject.on(:job_completed, &block)

        expect(subject.instance_variable_get(:@job_completed_callbacks)).to eq([block])
      end
    end

    context "for :job_failed event" do
      it "must pass block to #job_failed_callbacks" do
        subject.on(:job_failed, &block)

        expect(subject.instance_variable_get(:@job_failed_callbacks)).to eq([block])
      end
    end

    context "for unsupported event type" do
      it "must raise ArgumentError" do
        expect {
          subject.on(:foo, &block)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#enqueue_mesg" do
    before do
      Async { subject.add_worker(TestEngine::TestWorker) }
    end

    context "for Message::Value" do
      let(:mesg) { Ronin::Recon::Message::Value.new(value) }

      it "must add value to #value_status" do
        Async { subject.enqueue_mesg(mesg) }

        expect(subject.value_status.values).to eq({ value => { TestEngine::TestWorker => :enqueued } })
      end
    end

    context "for Message::SHUTDOWN" do
      let(:mesg) { Ronin::Recon::Message::Value.new(value) }

      it "must equeue message for each WorkerTask" do
        Async { subject.enqueue_mesg(mesg) }

        expect(subject.instance_variable_get(:@worker_tasks).values[0][0].instance_variable_get(:@input_queue).items).to eq([mesg])
      end
    end

    context "for other Messages" do
      let(:mesg) { Ronin::Recon::Message::WorkerStopped.new("foo") }

      it "must rais a NotImplementedError" do
        expect {
          subject.enqueue_mesg(mesg)
        }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#enqueue_value" do
    it "must add Value to #graph" do
      Async { subject.enqueue_value(value) }

      expect(subject.values).to eq(Set.new([value]))
    end
  end

  describe "#run" do
    before do
      # queue #output_queue
    end

    it "must dequeue #output_queue" do
      Async { subject.run }

      expect(subject.value_status).to be_empty
      expect(subject.instance_variable_get(:@output_queue)).to be_empty
    end
  end

  describe "#process" do
    let(:block) { proc { |f| "foo" } }

    context "for Message::WorkerStarded" do
      let(:mesg) { Ronin::Recon::Message::WorkerStarted.new(worker) }

      it "must increment #worker_task_count" do
        Async { subject.process(mesg) }

        expect(subject.instance_variable_get(:@worker_task_count)).to eq(1)
      end
    end

    context "for Message::WorkerStopped" do
      let(:mesg) { Ronin::Recon::Message::WorkerStopped.new(worker) }

      it "must decrement #worker_taks_count" do
        Async { subject.process(mesg) }

        expect(subject.instance_variable_get(:@worker_task_count)).to eq(-1)
      end
    end

    context "for Message::JobStarted" do
      let(:mesg) { Ronin::Recon::Message::JobStarted.new(worker, value) }

      before do
        Async { subject.on(:job_started, &block) }
      end

      it "must call all callbacks from #job_started_callbacks" do
        Async { subject.process(mesg) }
      end
    end

    context "for Message::JobCompleted" do
      let(:mesg) { Ronin::Recon::Message::JobCompleted.new(worker, value) }

      before do
        Async { subject.on(:job_completed, &block) }
      end

      it "must call all callbacks from #job_completed_callbacks" do
        Async { subject.process(mesg) }
      end
    end

    context "for Message::JobFailed" do
      let(:mesg) { Ronin::Recon::Message::JobFailed.new(worker, value, "ERROR") }

      before do
        Async { subject.on(:job_failed, &block) }
      end

      it "must call all callbacks from #job_completed_callbacks" do
        Async { subject.process(mesg) }
      end
    end

    context "for Message::Value" do
      let(:mesg) { Ronin::Recon::Message::Value.new(value, parent: value) }

      it "must add node and edge to #graph" do
        Async { subject.process(mesg) }

        expect(subject.instance_variable_get(:@graph).nodes).to eq(Set.new([value]))
        expect(subject.instance_variable_get(:@graph).edges).to eq({ value => Set.new([value]) })
      end
    end

    context "for not implemented Message" do
      let(:mesg) { Ronin::Recon::Message::Shutdown.new }

      it "must raise a NotImplementedError" do
        expect {
          Async { subject.process(mesg) }
        }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#start" do
    before do
      Async { subject.add_worker(TestEngine::TestWorker) }
    end

    it "must enqueue #scope values, output customer task and start all work groups" do
      Async { subject.start }

      expect(subject.values).to eq(Set.new([value]))
    end
  end

  describe "#shutdown!" do
    before do
      # enqueue #output_queue
    end

    it "must enqueue Message::SHUTDOWN and dequeue #output_queue" do
      Async { subject.shutdown! }

      expect(subject.instance_variable_get(:@worker_task_count)).to eq(0)
      expect(subject.instance_variable_get(:@output_queue)).to be_empty
    end
  end

  describe "#values" do
    context "for graph with nodes" do
      before do
        Async do
          subject.enqueue_value(value)
          subject.enqueue_value(value)
        end
      end

      it "must return Set of Values" do
        expect(subject.values).to eq(Set.new([value, value]))
      end
    end

    context "for graph without nodes" do
      it "must return empty Set" do
        expect(subject.values).to eq(Set.new)
      end
    end
  end
end
