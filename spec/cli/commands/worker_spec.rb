require 'spec_helper'
require 'ronin/recon/cli/commands/worker'
require 'ronin/recon/worker'

require 'fixtures/test_worker'

describe Ronin::Recon::CLI::Commands::Worker do
  describe "#run" do
    context "when given a worker name argument" do
      let(:name) { 'test_worker' }

      it "must load the worker and print it's information" do
        expect {
          subject.run(name)
        }.to output(
          <<~OUTPUT
            [ test_worker ]

              Summary: Test worker
              Authors:

                * Postmodern <postmodern.mod3@gmail.com>

              Description:

                This is a test worker.

              Accepts:

                * domain

              Outputs:

                * host

              Intensity: passive
              Params:

                ┌────────┬────────┬──────────┬─────────┬───────────────┐
                │  Name  │  Type  │ Required │ Default │  Description  │
                ├────────┼────────┼──────────┼─────────┼───────────────┤
                │ prefix │ String │ No       │ test    │ Example param │
                └────────┴────────┴──────────┴─────────┴───────────────┘

          OUTPUT
        ).to_stdout
      end
    end

    context "when given the '--file FILE' option instead of a worker name argument" do
      let(:fixtures_dir) { File.join(__dir__,'..','..','fixtures') }
      let(:path)         { File.join(fixtures_dir,'test_worker.rb') }

      before { subject.option_parser.parse(['--file', path]) }

      it "must load the worker from the file and print it's information" do
        expect {
          subject.run
        }.to output(
          <<~OUTPUT
            [ test_worker ]

              Summary: Test worker
              Authors:

                * Postmodern <postmodern.mod3@gmail.com>

              Description:

                This is a test worker.

              Accepts:

                * domain

              Outputs:

                * host

              Intensity: passive
              Params:

                ┌────────┬────────┬──────────┬─────────┬───────────────┐
                │  Name  │  Type  │ Required │ Default │  Description  │
                ├────────┼────────┼──────────┼─────────┼───────────────┤
                │ prefix │ String │ No       │ test    │ Example param │
                └────────┴────────┴──────────┴─────────┴───────────────┘

          OUTPUT
        ).to_stdout
      end
    end
  end

  describe "#print_worker" do
    let(:worker_class) { Ronin::Recon::TestWorker }

    it "must print the worker ID, authors, summary, description, accepted values, output values, intensity, and any params" do
      expect {
        subject.print_worker(worker_class)
      }.to output(
        <<~OUTPUT
          [ test_worker ]

            Summary: Test worker
            Authors:

              * Postmodern <postmodern.mod3@gmail.com>

            Description:

              This is a test worker.

            Accepts:

              * domain

            Outputs:

              * host

            Intensity: passive
            Params:

              ┌────────┬────────┬──────────┬─────────┬───────────────┐
              │  Name  │  Type  │ Required │ Default │  Description  │
              ├────────┼────────┼──────────┼─────────┼───────────────┤
              │ prefix │ String │ No       │ test    │ Example param │
              └────────┴────────┴──────────┴─────────┴───────────────┘

        OUTPUT
      ).to_stdout
    end

    context "when the worker class does not define `outputs`" do
      module TestWorkerCommand
        class WorkerWithoutOutputs < Ronin::Recon::Worker

          id 'worker_without_outputs'
          summary 'Test worker without `outputs`'
          description <<~DESC
            Test printing a worker without an `outputs`.
          DESC

          accepts URL
          intensity :passive

        end
      end

      let(:worker_class) { TestWorkerCommand::WorkerWithoutOutputs }

      it "must omit the 'Outputs:' line and list" do
        expect {
          subject.print_worker(worker_class)
        }.to output(
          <<~OUTPUT
            [ worker_without_outputs ]

              Summary: Test worker without `outputs`
              Description:

                Test printing a worker without an `outputs`.

              Accepts:

                * URL

              Intensity: passive
          OUTPUT
        ).to_stdout
      end
    end
  end
end
