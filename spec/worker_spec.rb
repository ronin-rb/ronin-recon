require 'spec_helper'
require 'ronin/recon/worker'

describe Ronin::Recon::Worker do
  it "must include Ronin::Core::Metadata::ID" do
    expect(described_class).to include(Ronin::Core::Metadata::ID)
  end

  it "must include Ronin::Core::Metadata::Authors" do
    expect(described_class).to include(Ronin::Core::Metadata::Authors)
  end

  it "must include Ronin::Core::Metadata::Summary" do
    expect(described_class).to include(Ronin::Core::Metadata::Summary)
  end

  it "must include Ronin::Core::Metadata::Description" do
    expect(described_class).to include(Ronin::Core::Metadata::Description)
  end

  it "must include Ronin::Core::Metadata::References" do
    expect(described_class).to include(Ronin::Core::Metadata::References)
  end

  it "must include Ronin::Core::Params::Mixin" do
    expect(described_class).to include(Ronin::Core::Params::Mixin)
  end

  describe ".register" do
    context "when .register is not called in the Worker class" do
      module TestWorkers
        class UnregisteredWorker < Ronin::Recon::Worker
        end
      end

      subject { TestWorkers::UnregisteredWorker }

      it "must not set .id" do
        expect(subject.id).to be(nil)
      end
    end

    context "when .register is called in the Worker class" do
      module TestWorkers
        class RegisteredWorker < Ronin::Recon::Worker
          register 'registered_worker'
        end
      end

      subject { TestWorkers::RegisteredWorker }

      it "must set .id" do
        expect(subject.id).to eq('registered_worker')
      end

      it "must add the exploit class to Recon.registry" do
        expect(Ronin::Recon.registry['registered_worker']).to be(subject)
      end
    end
  end

  describe ".accepts" do
    context "when the accepts is not set in the Worker class" do
      module TestWorkers
        class WorkerWithoutAccepts < Ronin::Recon::Worker
        end
      end

      subject { TestWorkers::WorkerWithoutAccepts }

      it "must raise a NotImplementedError excpetion when called" do
        expect {
          subject.accepts
        }.to raise_error(NotImplementedError,"#{subject} did not set accepts")
      end

      context "but the Worker class inherits from another worker class" do
        context "and the Worker's superclass defines accepts Value classes" do
          module TestWorkers
            class WorkerSuperclassWithAccepts < Ronin::Recon::Worker
              accepts Domain
            end

            class WorkerThatInheritsOtherWorker < WorkerSuperclassWithAccepts
            end
          end

          subject { TestWorkers::WorkerThatInheritsOtherWorker }

          it "must inherit the superclass'es accepts Value classes" do
            expect(subject.accepts).to eq(subject.superclass.accepts)
          end
        end
      end
    end

    context "when the accepts is set in the Worker class" do
      module TestWorkers
        class WorkerWithAccepts < Ronin::Recon::Worker
          accepts IP
        end
      end

      subject { TestWorkers::WorkerWithAccepts }

      it "must return the set accepts Ronin::Recon::Values:: classes" do
        expect(subject.accepts).to eq([Ronin::Recon::Values::IP])
      end

      context "and the Worker class defines multiple accepts Value classes" do
        module TestWorkers
          class WorkerWithMultipleAcceptsValues < Ronin::Recon::Worker
            accepts IP, Host, Domain
          end
        end

        subject { TestWorkers::WorkerWithMultipleAcceptsValues }

        it "must return the Array of the multiple Ronin::Recon::Values:: classes" do
          expect(subject.accepts).to eq(
            [
              Ronin::Recon::Values::IP,
              Ronin::Recon::Values::Host,
              Ronin::Recon::Values::Domain
            ]
          )
        end
      end

      context "but is differnet from the accepts defined in the superclass" do
        module TestWorkers
          class WorkerWithOverridenAccepts < WorkerWithAccepts
            accepts Host
          end
        end

        subject { TestWorkers::WorkerWithOverridenAccepts }

        it "must return the accepts set in the subclass" do
          expect(subject.accepts).to eq([Ronin::Recon::Values::Host])
        end

        it "must not change the accepts in the superclass" do
          expect(subject.superclass.accepts).to eq([Ronin::Recon::Values::IP])
        end
      end
    end
  end

  describe ".concurrency" do
    context "when the concurrency is not set in the Worker class" do
      module TestWorkers
        class WorkerWithoutConcurrency < Ronin::Recon::Worker
        end
      end

      subject { TestWorkers::WorkerWithoutConcurrency }

      it "must default to 1" do
        expect(subject.concurrency).to eq(1)
      end

      context "but is set in the superclass of the Worker class" do
        module TestWorkers
          class WorkerBaseClassWithConcurrency < Ronin::Recon::Worker
            concurrency 2
          end

          class WorkerWithInheritedConcurrency < WorkerBaseClassWithConcurrency
          end
        end

        subject { TestWorkers::WorkerWithInheritedConcurrency }

        it "must default to the concurrency defined in the superclass" do
          expect(subject.concurrency).to eq(subject.superclass.concurrency)
        end
      end
    end

    context "when the concurrency is set in the Worker class" do
      module TestWorkers
        class WorkerWithConcurrency < Ronin::Recon::Worker
          concurrency 4
        end
      end

      subject { TestWorkers::WorkerWithConcurrency }

      it "must return the set concurrency" do
        expect(subject.concurrency).to eq(4)
      end

      context "but is differnet from the concurrency defined in the superclass" do
        module TestWorkers
          class WorkerWithOverridenConcurrency < WorkerWithConcurrency
            concurrency 3
          end
        end

        subject { TestWorkers::WorkerWithOverridenConcurrency }

        it "must return the concurrency set in the subclass" do
          expect(subject.concurrency).to be(3)
        end

        it "must not change the concurrency in the superclass" do
          expect(subject.superclass.concurrency).to be(4)
        end
      end
    end
  end

  describe ".intensity" do
    context "when the intensity is not set in the Worker class" do
      module TestWorkers
        class WorkerWithoutIntensity < Ronin::Recon::Worker
        end
      end

      subject { TestWorkers::WorkerWithoutIntensity }

      it "must default to :active" do
        expect(subject.intensity).to be(:active)
      end

      context "but is set in the superclass of the Worker class" do
        module TestWorkers
          class WorkerBaseClassWithIntensity < Ronin::Recon::Worker
            intensity :passive
          end

          class WorkerWithInheritedIntensity < WorkerBaseClassWithIntensity
          end
        end

        subject { TestWorkers::WorkerWithInheritedIntensity }

        it "must default to the intensity defined in the superclass" do
          expect(subject.intensity).to eq(subject.superclass.intensity)
        end
      end
    end

    context "when the intensity is set in the Worker class" do
      module TestWorkers
        class WorkerWithIntensity < Ronin::Recon::Worker
          intensity :passive
        end
      end

      subject { TestWorkers::WorkerWithIntensity }

      it "must return the set intensity" do
        expect(subject.intensity).to be(:passive)
      end

      context "but is differnet from the intensity defined in the superclass" do
        module TestWorkers
          class WorkerWithOverridenIntensity < WorkerWithIntensity
            intensity :active
          end
        end

        subject { TestWorkers::WorkerWithOverridenIntensity }

        it "must return the intensity set in the subclass" do
          expect(subject.intensity).to be(:active)
        end

        it "must not change the intensity in the superclass" do
          expect(subject.superclass.intensity).to be(:passive)
        end
      end
    end
  end

  describe ".run" do
    module TestWorkers
      class TestWorker < Ronin::Recon::Worker
        accepts Host

        def process(host)
          yield IP.new('93.184.216.34')
          yield IP.new('2606:2800:220:1:248:1893:25c8:1946')
        end
      end
    end

    subject { TestWorkers::TestWorker }

    let(:value) { Ronin::Recon::Values::Host.new('example.com') }

    it "must pass the value to #process and yield back the yielded values" do
      expect { |b|
        subject.run(value,&b)
      }.to yield_successive_args(
        Ronin::Recon::Values::IP.new('93.184.216.34'),
        Ronin::Recon::Values::IP.new('2606:2800:220:1:248:1893:25c8:1946')
      )
    end
  end

  describe "#process" do
    module TestWorkers
      class WorkerWithoutProcessMethod < Ronin::Recon::Worker
      end
    end

    let(:worker_class) { TestWorkers::WorkerWithoutProcessMethod }
    subject { worker_class.new }

    let(:value) { Ronin::Recon::Values::IP.new('127.0.0.1') }

    it do
      expect {
        subject.process(value)
      }.to raise_error(NotImplementedError,"#{subject.class} did not define a #process method")
    end
  end
end
