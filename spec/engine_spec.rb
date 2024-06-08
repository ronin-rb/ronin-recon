require 'spec_helper'
require 'ronin/recon/engine'
require 'ronin/recon/worker'
require 'ronin/recon/dns_worker'
require 'ronin/recon/web_worker'

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

    it "must default #workers to the default set of workers" do
      expect(subject.workers).to eq(
        Ronin::Recon::Workers.load(Ronin::Recon::Config::Workers::DEFAULT)
      )
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

    context "when given the config_file: keyword argument" do
      let(:fixtures_dir) { File.join(__dir__,'fixtures') }
      let(:config_file)  { File.join(fixtures_dir,'config.yml') }
      let(:config)       { Ronin::Recon::Config.load(config_file) }

      subject { described_class.new(values, config_file: config_file) }

      it "must load the configuration from the file and set #config" do
        expect(subject.config).to eq(config)
      end

      it "must initialize #workers based on the `workers:` defined in the configuration file" do
        expect(subject.workers).to eq(
          Ronin::Recon::Workers.load(config.workers)
        )
      end
    end

    context "when given the config: keyword argument" do
      let(:config) do
        Ronin::Recon::Config.new(
          workers: %w[
            dns/lookup
            dns/reverse_lookup
            dns/nameservers
            dns/mailservers
          ]
        )
      end

      subject { described_class.new(values, config: config) }

      it "must set #config to the value passed in by the config: keyword argument" do
        expect(subject.config).to be(config)
      end

      it "must initialize #workers based on the #workers in the config value" do
        expect(subject.workers).to eq(
          Ronin::Recon::Workers.load(config.workers)
        )
      end

      context "and when the workers: keyword argument is given" do
        let(:workers) do
          Ronin::Recon::Workers.load(%w[
            dns/lookup
            dns/reverse_lookup
            dns/subdomain_enum
          ])
        end

        subject do
          described_class.new(values, config: config,
                                      workers: workers)
        end

        it "must set #workers to the workers: keyword argument value" do
          expect(subject.workers).to be(workers)
        end
      end
    end

    context "when given the workers: keyword argument" do
      let(:workers) do
        Ronin::Recon::Workers.load(
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

  module MockWorkers
    module DNS
      class Lookup < Ronin::Recon::DNSWorker

        accepts Domain, Host, Nameserver, Mailserver
        outputs IP

        def process(host)
          case host.name
          when 'example.com', 'www.example.com'
            yield IP.new('93.184.215.14', host: 'example.com')
          end
        end

      end

      class Nameservers < Ronin::Recon::DNSWorker

        accepts Domain
        outputs Nameserver

        def process(domain)
          if domain.name == 'example.com'
            yield Nameserver.new('a.iana-servers.net')
            yield Nameserver.new('b.iana-servers.net')
          end
        end

      end

      class Mailservers < Ronin::Recon::DNSWorker

        accepts Domain
        outputs Mailserver

        def process(domain)
        end

      end

      class ReverseLookup < Ronin::Recon::DNSWorker

        accepts IP
        outputs Host

        def process(ip)
        end

      end

      class SubdomainEnum < Ronin::Recon::DNSWorker

        accepts Domain
        outputs Host

        def process(domain)
          if domain.name == 'example.com'
            yield Host.new('www.example.com')
            yield Host.new('dev.example.com')
            yield Host.new('staging.example.com')
          end
        end

      end
    end

    module Net
      class PortScan < Ronin::Recon::Worker

        accepts IP
        outputs OpenPort

        def process(ip)
          if ip.address == '93.184.215.14'
            yield OpenPort.new(ip.address,80, host:     'example.com',
                                              protocol: :tcp,
                                              service:  'http',
                                              ssl:      false)

            yield OpenPort.new(ip.address,443, host:     'example.com',
                                               protocol: :tcp,
                                               service:  'https',
                                               ssl:      true)
          end
        end

      end
    end

    module Web
      class Spider < Ronin::Recon::WebWorker

        accepts Website
        outputs URL

        def process(website)
          if website.scheme == :http && website.host == 'example.com'
            yield URL.new(
              URI.parse('http://example.com/'), status: 200,
                                                headers: {
                                                  "content-type" => ["text/html; charset=UTF-8"]
                                                },
                                                body: "http page"
            )
          elsif website.scheme == :https && website.host == 'example.com'
            yield URL.new(
              URI.parse('https://example.com/'), status: 200,
                                                 headers: {
                                                   "content-type" => ["text/html; charset=UTF-8"]
                                                 },
                                                 body: "https page"
            )
          end
        end
      end
    end
  end

  let(:mock_workers) do
    Ronin::Recon::Workers.new(
      [
        MockWorkers::DNS::Lookup,
        MockWorkers::DNS::Nameservers,
        MockWorkers::DNS::Mailservers,
        MockWorkers::DNS::ReverseLookup,
        MockWorkers::DNS::SubdomainEnum,
        MockWorkers::Net::PortScan,
        Ronin::Recon::Net::ServiceID,
        MockWorkers::Web::Spider
      ]
    )
  end

  let(:domain_value) do
    Ronin::Recon::Values::Domain.new('example.com')
  end
  let(:values) { [domain_value] }

  describe ".run" do
    subject { described_class }

    let(:ip_value1) do
      Ronin::Recon::Values::IP.new('93.184.215.14', host: 'example.com')
    end
    let(:host_value1) do
      Ronin::Recon::Values::Host.new('www.example.com')
    end
    let(:host_value2) do
      Ronin::Recon::Values::Host.new('dev.example.com')
    end
    let(:host_value3) do
      Ronin::Recon::Values::Host.new('staging.example.com')
    end
    let(:open_port_value1) do
      Ronin::Recon::Values::OpenPort.new(
        '93.184.215.14',80, host:     'example.com',
                            protocol: :tcp,
                            service:  'http',
                            ssl:      false
      )
    end
    let(:open_port_value2) do
      Ronin::Recon::Values::OpenPort.new(
        '93.184.215.14',443, host:     'example.com',
                             protocol: :tcp,
                             service:  'https',
                             ssl:      true
      )
    end
    let(:website_value1) do
      Ronin::Recon::Values::Website.new(:http,'example.com',80)
    end
    let(:website_value2) do
      Ronin::Recon::Values::Website.new(:https,'example.com',443)
    end
    let(:url_value1) do
      Ronin::Recon::Values::URL.new(
        URI.parse('http://example.com/'), status: 200,
                                          headers: {
                                            "content-type" => ["text/html; charset=UTF-8"]
                                          },
                                          body: "http page"
      )
    end
    let(:url_value2) do
      Ronin::Recon::Values::URL.new(
        URI.parse('https://example.com/'), status: 200,
                                           headers: {
                                             "content-type" => ["text/html; charset=UTF-8"]
                                           },
                                           body: "https page"
      )
    end
    let(:expected_values) do
      [
        ip_value1,
        host_value1,
        host_value2,
        host_value3,
        open_port_value1,
        open_port_value2,
        website_value1,
        website_value2,
        url_value1,
        url_value2
      ]
    end

    it "must run the engine until there are no more new values and populate #graph with all discovered values" do
      engine = subject.run(values, workers: mock_workers)

      expect(engine.graph.nodes).to eq(
        Set.new(values + expected_values)
      )

      expect(engine.graph[host_value1]).to eq(Set[domain_value])
      expect(engine.graph[host_value2]).to eq(Set[domain_value])
      expect(engine.graph[host_value3]).to eq(Set[domain_value])
      expect(engine.graph[ip_value1]).to eq(Set[domain_value, host_value1])
      expect(engine.graph[open_port_value1]).to eq(Set[ip_value1])
      expect(engine.graph[open_port_value2]).to eq(Set[ip_value1])
      expect(engine.graph[website_value1]).to eq(Set[open_port_value1])
      expect(engine.graph[website_value2]).to eq(Set[open_port_value2])
      expect(engine.graph[url_value1]).to eq(Set[website_value1])
      expect(engine.graph[url_value2]).to eq(Set[website_value2])
    end

    context "when the ignore: keyword argument is given" do
      let(:ignore) do
        [
          Ronin::Recon::Values::Host.new('staging.example.com'),
          Ronin::Recon::Values::Host.new('dev.example.com')
        ]
      end

      it "must ignore the values that match the values in the ignore: list" do
        engine = subject.run(values, ignore:  ignore,
                                     workers: mock_workers)

        expect(engine.graph.nodes).to eq(
          Set[
            domain_value,
            ip_value1,
            host_value1,
            open_port_value1,
            open_port_value2,
            website_value1,
            website_value2,
            url_value1,
            url_value2
          ]
        )

        expect(engine.graph[host_value1]).to eq(Set[domain_value])
        expect(engine.graph[ip_value1]).to eq(Set[domain_value, host_value1])
        expect(engine.graph[open_port_value1]).to eq(Set[ip_value1])
        expect(engine.graph[open_port_value2]).to eq(Set[ip_value1])
        expect(engine.graph[website_value1]).to eq(Set[open_port_value1])
        expect(engine.graph[website_value2]).to eq(Set[open_port_value2])
        expect(engine.graph[url_value1]).to eq(Set[website_value1])
        expect(engine.graph[url_value2]).to eq(Set[website_value2])
      end
    end

    context "when the max_depth: keyword argument is given" do
      let(:max_depth) { 2 }

      it "must only perform recon to the maximum depth" do
        engine = subject.run(values, max_depth: max_depth,
                                     workers:   mock_workers)

        expect(engine.graph.nodes).to eq(
          Set[
            domain_value,
            ip_value1,
            host_value1,
            host_value2,
            host_value3,
            open_port_value1,
            open_port_value2,
          ]
        )

        expect(engine.graph[host_value1]).to eq(Set[domain_value])
        expect(engine.graph[host_value2]).to eq(Set[domain_value])
        expect(engine.graph[host_value3]).to eq(Set[domain_value])
        expect(engine.graph[ip_value1]).to eq(Set[domain_value, host_value1])
        expect(engine.graph[open_port_value1]).to eq(Set[ip_value1])
        expect(engine.graph[open_port_value2]).to eq(Set[ip_value1])
      end
    end

    context "when given a block" do
      context "and it registers an on(:job_started) callback" do
        it "must yield every worker class and value that will be processed" do
          yielded_args = []

          subject.run(values, workers: mock_workers) do |engine|
            engine.on(:job_started) do |worker,value|
              yielded_args << [worker, value]
            end
          end

          expect(yielded_args).to match_array(
            [
              [MockWorkers::DNS::Lookup, domain_value],
              [MockWorkers::DNS::Nameservers, domain_value],
              [MockWorkers::DNS::Mailservers, domain_value],
              [MockWorkers::DNS::SubdomainEnum, domain_value],
              [MockWorkers::DNS::Lookup, host_value1],
              [MockWorkers::DNS::Lookup, host_value2],
              [MockWorkers::DNS::Lookup, host_value3],
              [MockWorkers::DNS::ReverseLookup, ip_value1],
              [MockWorkers::Net::PortScan, ip_value1],
              [Ronin::Recon::Net::ServiceID, open_port_value1],
              [Ronin::Recon::Net::ServiceID, open_port_value2],
              [MockWorkers::Web::Spider, website_value1],
              [MockWorkers::Web::Spider, website_value2]
            ]
          )
        end
      end

      context "and it registers an on(:job_completed) callback" do
        it "must yield every worker class and value that has been processed" do
          yielded_args = []

          subject.run(values, workers: mock_workers) do |engine|
            engine.on(:job_completed) do |worker,value|
              yielded_args << [worker, value]
            end
          end

          expect(yielded_args).to match_array(
            [
              [MockWorkers::DNS::Lookup, domain_value],
              [MockWorkers::DNS::Nameservers, domain_value],
              [MockWorkers::DNS::Mailservers, domain_value],
              [MockWorkers::DNS::SubdomainEnum, domain_value],
              [MockWorkers::DNS::Lookup, host_value1],
              [MockWorkers::DNS::Lookup, host_value2],
              [MockWorkers::DNS::Lookup, host_value3],
              [MockWorkers::DNS::ReverseLookup, ip_value1],
              [MockWorkers::Net::PortScan, ip_value1],
              [Ronin::Recon::Net::ServiceID, open_port_value1],
              [Ronin::Recon::Net::ServiceID, open_port_value2],
              [MockWorkers::Web::Spider, website_value1],
              [MockWorkers::Web::Spider, website_value2]
            ]
          )
        end
      end

      context "and it registers an on(:job_failed) callback" do
        context "and one of the values causes an exception to be raised by a worker" do
          module MockWorkers
            class WorkerThatRaisesAnError < Ronin::Recon::Worker

              accepts URL
              outputs URL

              def process(url)
                if url.uri == URI('https://example.com/')
                  raise("failed to process URL: #{url}")
                end
              end

            end

            class WorkerThatAlwaysRaisesAnError < Ronin::Recon::Worker

              accepts Domain, Host
              outputs Host

              def process(host)
                raise("failed to process host: #{host}")
              end

            end
          end

          let(:mock_workers) do
            super() + [
              MockWorkers::WorkerThatRaisesAnError,
              MockWorkers::WorkerThatAlwaysRaisesAnError
            ]
          end

          it "must yield every worker class, value, and exception raised by a worker" do
            yielded_args = []

            subject.run(values, workers: mock_workers) do |engine|
              engine.on(:job_failed) do |worker,value,exception|
                yielded_args << [worker, value, exception]
              end
            end

            expect(yielded_args[0][0]).to eq(MockWorkers::WorkerThatAlwaysRaisesAnError)
            expect(yielded_args[0][1]).to eq(domain_value)
            expect(yielded_args[0][2].class).to eq(RuntimeError)
            expect(yielded_args[0][2].message).to eq("failed to process host: #{domain_value}")

            expect(yielded_args[1][0]).to eq(MockWorkers::WorkerThatAlwaysRaisesAnError)
            expect(yielded_args[1][1]).to eq(host_value1)
            expect(yielded_args[1][2].class).to eq(RuntimeError)
            expect(yielded_args[1][2].message).to eq("failed to process host: #{host_value1}")

            expect(yielded_args[2][0]).to eq(MockWorkers::WorkerThatAlwaysRaisesAnError)
            expect(yielded_args[2][1]).to eq(host_value2)
            expect(yielded_args[2][2].class).to eq(RuntimeError)
            expect(yielded_args[2][2].message).to eq("failed to process host: #{host_value2}")

            expect(yielded_args[3][0]).to eq(MockWorkers::WorkerThatAlwaysRaisesAnError)
            expect(yielded_args[3][1]).to eq(host_value3)
            expect(yielded_args[3][2].class).to eq(RuntimeError)
            expect(yielded_args[3][2].message).to eq("failed to process host: #{host_value3}")

            expect(yielded_args[4][0]).to eq(MockWorkers::WorkerThatRaisesAnError)
            expect(yielded_args[4][1]).to eq(url_value2)
            expect(yielded_args[4][2].class).to eq(RuntimeError)
            expect(yielded_args[4][2].message).to eq("failed to process URL: #{url_value2}")
          end
        end

        context "but no exceptions are raised by any workers" do
          it "must not yield" do
            yielded_args = []

            subject.run(values, workers: mock_workers) do |engine|
              engine.on(:job_failed) do |worker,value,exception|
                yielded_args << [worker, value, exception]
              end
            end

            expect(yielded_args).to be_empty
          end
        end
      end

      context "and it registers an on(:value) callback" do
        it "must yield every discovered value that is in scope of the initial values" do
          yielded_values = []

          subject.run(values, workers: mock_workers) do |engine|
            engine.on(:value) do |value|
              yielded_values << value
            end
          end

          expect(yielded_values).to match_array(expected_values)
        end

        context "and the block accepts two arguments" do
          it "must yield every discovered value and it's parent value" do
            yielded_args = []

            subject.run(values, workers: mock_workers) do |engine|
              engine.on(:value) do |value,parent|
                yielded_args << [value,parent]
              end
            end

            expect(yielded_args).to match_array(
              [
                [ip_value1, domain_value],
                [host_value1, domain_value],
                [host_value2, domain_value],
                [host_value3, domain_value],
                [open_port_value1, ip_value1],
                [open_port_value2, ip_value1],
                [website_value1, open_port_value1],
                [website_value2, open_port_value2],
                [url_value1, website_value1],
                [url_value2, website_value2]
              ]
            )
          end
        end

        context "and the block accepts three arguments" do
          it "must yield every discovered value, it's parent value, and the worker class which discovered the value" do
            yielded_argss = []

            subject.run(values, workers: mock_workers) do |engine|
              engine.on(:value) do |worker,value,parent|
                yielded_argss << [worker,value,parent]
              end
            end

            expect(yielded_argss).to match_array(
              [
                [MockWorkers::DNS::Lookup, ip_value1, domain_value],
                [MockWorkers::DNS::SubdomainEnum, host_value1, domain_value],
                [MockWorkers::DNS::SubdomainEnum, host_value2, domain_value],
                [MockWorkers::DNS::SubdomainEnum, host_value3, domain_value],
                [MockWorkers::Net::PortScan, open_port_value1, ip_value1],
                [MockWorkers::Net::PortScan, open_port_value2, ip_value1],
                [Ronin::Recon::Net::ServiceID, website_value1, open_port_value1],
                [Ronin::Recon::Net::ServiceID, website_value2, open_port_value2],
                [MockWorkers::Web::Spider, url_value1, website_value1],
                [MockWorkers::Web::Spider, url_value2, website_value2]
              ]
            )
          end
        end
      end

      context "and it registers an on(:connection) callback" do
        it "must yield every discovered value and it's parent value" do
          yielded_args = []

          subject.run(values, workers: mock_workers) do |engine|
            engine.on(:connection) do |value,parent|
              yielded_args << [value,parent]
            end
          end

          expect(yielded_args).to match_array(
            [
              [ip_value1, domain_value],
              [host_value1, domain_value],
              [host_value2, domain_value],
              [host_value3, domain_value],
              [ip_value1, host_value1],
              [open_port_value1, ip_value1],
              [open_port_value2, ip_value1],
              [website_value1, open_port_value1],
              [website_value2, open_port_value2],
              [url_value1, website_value1],
              [url_value2, website_value2]
            ]
          )
        end

        context "and the block accepts three arguments" do
          it "must yield every discovered value, it's parent value, and the worker class which discovered the value" do
            yielded_args = []

            subject.run(values, workers: mock_workers) do |engine|
              engine.on(:connection) do |worker,value,parent|
                yielded_args << [worker,value,parent]
              end
            end

            expect(yielded_args).to match_array(
              [
                [MockWorkers::DNS::Lookup, ip_value1, domain_value],
                [MockWorkers::DNS::SubdomainEnum, host_value1, domain_value],
                [MockWorkers::DNS::SubdomainEnum, host_value2, domain_value],
                [MockWorkers::DNS::SubdomainEnum, host_value3, domain_value],
                [MockWorkers::DNS::Lookup, ip_value1, host_value1],
                [MockWorkers::Net::PortScan, open_port_value1, ip_value1],
                [MockWorkers::Net::PortScan, open_port_value2, ip_value1],
                [Ronin::Recon::Net::ServiceID, website_value1, open_port_value1],
                [Ronin::Recon::Net::ServiceID, website_value2, open_port_value2],
                [MockWorkers::Web::Spider, url_value1, website_value1],
                [MockWorkers::Web::Spider, url_value2, website_value2]
              ]
            )
          end
        end
      end
    end
  end
end
