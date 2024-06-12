require 'spec_helper'
require 'ronin/recon/cli/commands/worker'
require 'ronin/recon/worker'

describe Ronin::Recon::CLI::Commands::Worker do
  describe "#run" do
    context "when given a worker name argument" do
      let(:name) { 'dns/lookup' }

      it "must load the worker and print it's information" do
        expect {
          subject.run(name)
        }.to output(
          <<~OUTPUT
            [ dns/lookup ]

              Summary: Looks up the IPs of a host-name
              Description:

                Resolves the IP addresses of domains, host names, nameservers,
                and mailservers.

              Accepts:

                * domain
                * host
                * nameserver
                * mailserver

              Outputs:

                * IP address

              Intensity: passive
          OUTPUT
        ).to_stdout
      end
    end

    context "when given the '--file FILE' option" do
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
          OUTPUT
        ).to_stdout
      end
    end
  end

  describe "#print_worker" do
    module TestWorkerCommand
      class TestWorker < Ronin::Recon::Worker

        register 'test_worker'

        summary 'Test worker'
        description <<~DESC
          This is a test worker.
        DESC
        author 'Postmodern', email: 'postmodern.mod3@gmail.com'

        accepts Domain, Host
        outputs IP

        param :foo, desc: 'Example param'

      end
    end

    let(:worker_class) { TestWorkerCommand::TestWorker }

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
              * host

            Outputs:

              * IP address

            Intensity: active
            Params:

              ┌──────┬────────┬──────────┬─────────┬───────────────┐
              │ Name │  Type  │ Required │ Default │  Description  │
              ├──────┼────────┼──────────┼─────────┼───────────────┤
              │ foo  │ String │ No       │         │ Example param │
              └──────┴────────┴──────────┴─────────┴───────────────┘

        OUTPUT
      ).to_stdout
    end
  end
end
