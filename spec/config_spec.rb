require 'spec_helper'
require 'ronin/recon/config'

require 'tmpdir'

describe Ronin::Recon::Config do
  describe described_class::Workers do
    describe "#initialize" do
      context "when given a Set" do
        let(:set) { Set['dns/lookup', 'web/dir_enum'] }

        subject { described_class.new(set) }

        it "must duplicate the set" do
          expect(subject.ids).to eq(set)
          expect(subject.ids).to_not be(set)
        end
      end

      context "when given an Array" do
        let(:array) { %w[dns/lookup web/dir_enum] }

        subject { described_class.new(array) }

        it "must initialize #set as a Set using the array" do
          expect(subject.ids).to eq(array.to_set)
        end
      end

      context "when given a Hash" do
        let(:hash) do
          {
            'dns/lookup'    => true,
            'web/dir_enum'  => true,
            'net/port_scan' => false
          }
        end

        subject { described_class.new(hash) }

        it "must return a new #{described_class} containing the keys in the Hash with true values" do
          expect(subject).to be_kind_of(described_class)
          expect(subject.ids).to include('dns/lookup')
          expect(subject.ids).to include('web/dir_enum')
          expect(subject.ids).to_not include('net/port_scan')
        end
      end

      context "when given another type of Object" do
        let(:value) { Object.new }

        it "raise an ArgumentError" do
          expect {
            described_class.new(value)
          }.to raise_error("workers value must be a Set, Array, or Hash: #{value.inspect}")
        end
      end
    end

    describe ".default" do
      subject { described_class.default }

      it "must initialize the worker set to the default set of workers" do
        expect(subject.ids).to eq(described_class::DEFAULT)
      end
    end

    let(:set) do
      Set[
        'dns/lookup',
        'web/dir_enum'
      ]
    end

    subject { described_class.new(set) }

    describe "#add" do
      let(:worker_id) { 'dns/new_worker' }

      it "must add the worker ID to the worker set" do
        subject.add(worker_id)

        expect(subject).to include(worker_id)
      end

      it "must return self" do
        expect(subject.add(worker_id)).to be(subject)
      end
    end

    describe "#delete" do
      let(:worker_id) { 'dns/lookup' }

      it "must remove the worker ID to the worker set" do
        subject.delete(worker_id)

        expect(subject).to_not include(worker_id)
      end

      it "must return self" do
        expect(subject.delete(worker_id)).to be(subject)
      end
    end

    describe "#include?" do
      context "when the worker ID is in the worker set" do
        let(:worker_id) { 'web/dir_enum' }

        it "must return true" do
          expect(subject.include?(worker_id)).to be(true)
        end
      end

      context "when the worker ID is not in the worker set" do
        let(:worker_id) { 'dns/not_in_the_set' }

        it "must return false" do
          expect(subject.include?(worker_id)).to be(false)
        end
      end
    end

    describe "#each" do
      context "when given a block" do
        it "must yield each worker ID in the worker set" do
          expect { |b|
            subject.each(&b)
          }.to yield_successive_args(*set)
        end
      end

      context "when no block is given" do
        it "must return an Enumerator object" do
          expect(subject.each).to be_kind_of(Enumerator)
          expect(subject.each.to_a).to eq(set.to_a)
        end
      end
    end

    describe "#eql?" do
      context "when given another #{described_class} object" do
        context "and it contains the same #workers" do
          let(:other) { described_class.new(set) }

          it "must return true" do
            expect(subject.eql?(other)).to be(true)
          end
        end

        context "but it contains different #workers" do
          let(:other_set) do
            Set[
              'dns/lookup',
              'net/port_scan'
            ]
          end
          let(:other) { described_class.new(other_set) }

          it "must return false" do
            expect(subject.eql?(other)).to be(false)
          end
        end
      end

      context "when given another kind of object" do
        let(:other) { Object.new }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end

    describe "#to_h" do
      context "when initialized the default set of workers" do
        subject { described_class.default }

        it "must return an empty Hash" do
          expect(subject.to_h).to eq({})
        end
      end

      context "when given a Set" do
        let(:set) { Set['dns/lookup', 'web/dir_enum', 'web/new_worker'] }

        subject { described_class.new(set) }

        it "must return a Hash with the worker IDs from the default, that are not in the array, disabled and the worker IDs that are not in the default set, but in the array, enabled" do
          expect(subject.to_h).to eq(
            {
              'dns/mailservers'     => false,
              'dns/nameservers'     => false,
              'dns/reverse_lookup'  => false,
              'dns/srv_enum'        => false,
              'dns/subdomain_enum'  => false,
              'dns/suffix_enum'     => false,
              'net/ip_range_enum'   => false,
              'net/port_scan'       => false,
              'net/service_id'      => false,
              'ssl/cert_enum'       => false,
              'ssl/cert_grab'       => false,
              'web/email_addresses' => false,
              'web/new_worker'      => true,
              'web/spider'          => false
            }
          )
        end
      end

      context "when given an Array" do
        let(:array) { %w[dns/lookup web/dir_enum web/new_worker] }

        subject { described_class.new(array) }

        it "must return a Hash with the worker IDs from the default, that are not in the array, disabled and the worker IDs that are not in the default set, but in the array, enabled" do
          expect(subject.to_h).to eq(
            {
              'dns/mailservers'     => false,
              'dns/nameservers'     => false,
              'dns/reverse_lookup'  => false,
              'dns/srv_enum'        => false,
              'dns/subdomain_enum'  => false,
              'dns/suffix_enum'     => false,
              'net/ip_range_enum'   => false,
              'net/port_scan'       => false,
              'net/service_id'      => false,
              'ssl/cert_enum'       => false,
              'ssl/cert_grab'       => false,
              'web/email_addresses' => false,
              'web/new_worker'      => true,
              'web/spider'          => false
            }
          )
        end
      end

      context "when initialized with a Hash" do
        let(:hash) do
          {
            'dns/lookup'     => true,
            'web/dir_enum'   => true,
            'net/port_scan'  => false,
            'web/new_worker' => true
          }
        end

        subject { described_class.new(hash) }

        it "must return a Hash with the worker IDs that are disabled and enabled, which are not already in the default set" do
          expect(subject.to_h).to eq(
            {
              'net/port_scan'  => false,
              'web/new_worker' => true
            }
          )
        end
      end
    end
  end

  describe "#initialize" do
    it "must initialize #workers to #{described_class}::Workers.new" do
      expect(subject.workers).to eq(described_class::Workers.default)
    end

    it "must initialize #params to an empty Hash" do
      expect(subject.params).to eq({})
    end

    it "must initialize #concurrency to an empty Hash" do
      expect(subject.concurrency).to eq({})
    end
  end

  describe "#workers" do
    it "must return a #{described_class}::Workers" do
      expect(subject.workers).to be_kind_of(described_class::Workers)
    end
  end

  describe "#params" do
    it "must return a Hash" do
      expect(subject.params).to be_kind_of(Hash)
    end
  end

  describe "#concurrency" do
    it "must return a Hash" do
      expect(subject.concurrency).to be_kind_of(Hash)
    end
  end

  describe "DEFAULT_PATH" do
    subject { described_class::DEFAULT_PATH }

    it "must equal '~/.config/ronin-recon/config.yml'" do
      expect(subject).to eq(File.expand_path('~/.config/ronin-recon/config.yml'))
    end
  end

  let(:fixtures_dir) { File.join(__dir__,'fixtures','config') }

  describe ".validate" do
    subject { described_class }

    let(:yaml) { YAML.load_file(path) }

    context "when the file does not contain a YAML Hash" do
      let(:path) { File.join(fixtures_dir,'does_not_contain_a_hash.yml') }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"must contain a Hash: #{yaml.inspect}")
      end
    end

    context "when the file contains invalid `workers:` value" do
      let(:path)  { File.join(fixtures_dir,'invalid_workers.yml') }
      let(:value) { yaml.fetch(:workers) }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"workers value must be a Hash or an Array: #{value.inspect}")
      end
    end

    context "when the file contains invalid `:params:` value" do
      let(:path)  { File.join(fixtures_dir,'invalid_params.yml') }
      let(:value) { yaml.fetch(:params) }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"params value must be a Hash: #{value.inspect}")
      end
    end

    context "when the file contains a non-String worker ID in `:params:`" do
      let(:path)      { File.join(fixtures_dir,'invalid_params_sub_key.yml') }
      let(:worker_id) { yaml.fetch(:params).keys.first }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"worker ID must be a String: #{worker_id.inspect}")
      end
    end

    context "when the file contains a non-Hash value for a worker ID in `:params:`" do
      let(:path)        { File.join(fixtures_dir,'invalid_params_sub_value.yml') }
      let(:worker_id)   { yaml.fetch(:params).keys.first }
      let(:params_hash) { yaml.fetch(:params).values.first }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"params value for worker (#{worker_id.inspect}) must be a Hash: #{params_hash.inspect}")
      end
    end

    context "when the file contains a non-Symbol sub-key within a `:params:` hash" do
      let(:path)      { File.join(fixtures_dir,'invalid_params_sub_sub_key.yml') }
      let(:worker_id) { yaml.fetch(:params).keys.first }
      let(:param_key) { yaml.fetch(:params).values.first.keys.first }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"param key for worker (#{worker_id.inspect}) must be a Symbol: #{param_key.inspect}")
      end
    end

    context "when the file contains invalid `:concurrency:` value" do
      let(:path)  { File.join(fixtures_dir,'invalid_concurrency.yml') }
      let(:value) { yaml.fetch(:concurrency) }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"concurrency value must be a Hash: #{value.inspect}")
      end
    end

    context "when the file contains invalid `:concurrency:` sub-key" do
      let(:path)      { File.join(fixtures_dir,'invalid_concurrency_sub_key.yml') }
      let(:worker_id) { yaml.fetch(:concurrency).keys.first }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"worker ID must be a String: #{worker_id.inspect}")
      end
    end

    context "when the file contains invalid `:concurrency:` sub-value" do
      let(:path)        { File.join(fixtures_dir,'invalid_concurrency_sub_value.yml') }
      let(:worker_id)   { yaml.fetch(:concurrency).keys.first }
      let(:concurrency) { yaml.fetch(:concurrency).values.first }

      it do
        expect {
          subject.validate(yaml)
        }.to raise_error(Ronin::Recon::InvalidConfig,"concurrency value for worker (#{worker_id.inspect}) must be an Integer: #{concurrency.inspect}")
      end
    end
  end

  describe ".load" do
    subject { described_class }

    let(:path) { File.join(fixtures_dir,'config.yml') }
    let(:yaml) { YAML.load_file(path) }

    context "when the YAML file contains a ':workers:' key" do
      let(:path) { File.join(fixtures_dir,'with_workers.yml') }

      subject { described_class.load(path) }

      it "must return a #{described_class} object" do
        expect(subject).to be_kind_of(described_class)
      end

      it "must parse and populate #workers" do
        expect(subject.workers).to be_kind_of(described_class::Workers)
        expect(subject.workers.ids).to eq(
          Set['test/worker1', 'test/worker2', 'test/worker3']
        )
      end
    end

    context "when the YAML file contains a ':params:' key" do
      let(:path) { File.join(fixtures_dir,'with_params.yml') }

      subject { described_class.load(path) }

      it "must return a #{described_class} object" do
        expect(subject).to be_kind_of(described_class)
      end

      it "must parse and populate #params" do
        expect(subject.params).to be_kind_of(Hash)
        expect(subject.params['test/worker1']).to eq(
          {
            foo: 'a',
            bar: 'b'
          }
        )
        expect(subject.params['test/worker2']).to eq(
          {
            foo: 'x',
            bar: 'y'
          }
        )
      end
    end

    context "when the YAML file contains a ':concurrency:' key" do
      let(:path) { File.join(fixtures_dir,'with_concurrency.yml') }

      subject { described_class.load(path) }

      it "must return a #{described_class} object" do
        expect(subject).to be_kind_of(described_class)
      end

      it "must parse and populate #workers" do
        expect(subject.concurrency).to be_kind_of(Hash)
        expect(subject.concurrency['test/worker1']).to eq(3)
        expect(subject.concurrency['test/worker2']).to eq(42)
      end
    end

    context "when the file does not contain a YAML Hash" do
      let(:path) { File.join(fixtures_dir,'does_not_contain_a_hash.yml') }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): must contain a Hash: #{yaml.inspect}")
      end
    end

    context "when the file contains invalid `:workers:` value" do
      let(:path)  { File.join(fixtures_dir,'invalid_workers.yml') }
      let(:value) { yaml.fetch(:workers) }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): workers value must be a Hash or an Array: #{value.inspect}")
      end
    end

    context "when the file contains invalid `:params:` value" do
      let(:path)  { File.join(fixtures_dir,'invalid_params.yml') }
      let(:value) { yaml.fetch(:params) }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): params value must be a Hash: #{value.inspect}")
      end
    end

    context "when the file contains a non-String worker ID in `:params:`" do
      let(:path)      { File.join(fixtures_dir,'invalid_params_sub_key.yml') }
      let(:worker_id) { yaml.fetch(:params).keys.first }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): worker ID must be a String: #{worker_id.inspect}")
      end
    end

    context "when the file contains a non-Hash value for a worker ID in `:params:`" do
      let(:path)        { File.join(fixtures_dir,'invalid_params_sub_value.yml') }
      let(:worker_id)   { yaml.fetch(:params).keys.first }
      let(:params_hash) { yaml.fetch(:params).values.first }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): params value for worker (#{worker_id.inspect}) must be a Hash: #{params_hash.inspect}")
      end
    end

    context "when the file contains a non-Symbol sub-key within a `:params:` hash" do
      let(:path)      { File.join(fixtures_dir,'invalid_params_sub_sub_key.yml') }
      let(:worker_id) { yaml.fetch(:params).keys.first }
      let(:param_key) { yaml.fetch(:params).values.first.keys.first }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): param key for worker (#{worker_id.inspect}) must be a Symbol: #{param_key.inspect}")
      end
    end

    context "when the file contains invalid `:concurrency:` value" do
      let(:path)  { File.join(fixtures_dir,'invalid_concurrency.yml') }
      let(:value) { yaml.fetch(:concurrency) }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): concurrency value must be a Hash: #{value.inspect}")
      end
    end

    context "when the file contains invalid `:concurrency:` sub-key" do
      let(:path)      { File.join(fixtures_dir,'invalid_concurrency_sub_key.yml') }
      let(:worker_id) { yaml.fetch(:concurrency).keys.first }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): worker ID must be a String: #{worker_id.inspect}")
      end
    end

    context "when the file contains invalid `:concurrency:` sub-value" do
      let(:path)        { File.join(fixtures_dir,'invalid_concurrency_sub_value.yml') }
      let(:worker_id)   { yaml.fetch(:concurrency).keys.first }
      let(:concurrency) { yaml.fetch(:concurrency).values.first }

      it do
        expect {
          subject.load(path)
        }.to raise_error(Ronin::Recon::InvalidConfigFile,"invalid config file (#{path.inspect}): concurrency value for worker (#{worker_id.inspect}) must be an Integer: #{concurrency.inspect}")
      end
    end
  end

  describe ".default" do
    subject { described_class }

    context "when the '~/.config/ronin-recon/config.yml' file exists" do
      before do
        expect(File).to receive(:file?).with(described_class::DEFAULT_PATH).and_return(true)
      end

      let(:config) { double('Ronin::Recon::Config') }

      it "must load the '~/.config/ronin-recon/config.yml' YAML file" do
        expect(subject).to receive(:load).with(described_class::DEFAULT_PATH).and_return(config)

        expect(subject.default).to be(config)
      end
    end

    context "when the '~/.config/ronin-recon/config.yml' file does not exist" do
      before do
        expect(File).to receive(:file?).with(described_class::DEFAULT_PATH).and_return(false)
      end

      it "must return a new #{described_class}" do
        config = subject.default

        expect(config).to be_kind_of(described_class)
        expect(config.workers).to eq(described_class::Workers.default)
        expect(config.params).to eq({})
        expect(config.concurrency).to eq({})
      end
    end
  end

  describe "#workers=" do
    context "when given a #{described_class}::Workers object" do
      let(:new_workers) do
        described_class::Workers.new(
          Set['dns/lookup', 'dns/reverse_lookup']
        )
      end

      before { subject.workers = new_workers }

      it "must set #workers" do
        expect(subject.workers).to be(new_workers)
      end
    end

    context "when given a Set object" do
      let(:new_workers) { Set['dns/lookup', 'dns/reverse_lookup'] }

      before { subject.workers = new_workers }

      it "must reset #workers" do
        expect(subject.workers).to be_kind_of(described_class::Workers)
        expect(subject.workers.ids).to eq(new_workers)
      end
    end

    context "when given a Array object" do
      let(:new_workers) { ['dns/lookup', 'dns/reverse_lookup'] }

      before { subject.workers = new_workers }

      it "must reset #workers" do
        expect(subject.workers).to be_kind_of(described_class::Workers)
        expect(subject.workers.ids).to eq(new_workers.to_set)
      end
    end

    context "when given a Hash object" do
      let(:new_workers) do
        {
          'dns/lookup'    => true,
          'web/dir_enum'  => true,
          'net/port_scan' => false
        }
      end

      before { subject.workers = new_workers }

      it "must reset #workers" do
        expect(subject.workers).to be_kind_of(described_class::Workers)
        expect(subject.workers).to include('dns/lookup')
        expect(subject.workers).to include('web/dir_enum')
        expect(subject.workers).to_not include('net/port_scan')
      end
    end

    context "when given another kind of object" do
      let(:new_workers) { Object.new }

      it do
        expect {
          subject.workers = new_workers
        }.to raise_error(ArgumentError,"new workers value must be a #{described_class::Workers}, Set, Array, or Hash: #{new_workers.inspect}")
      end
    end
  end

  describe "#eql?" do
    let(:workers) do
      described_class::Workers.new(
        Set[
          'test/worker1',
          'test/worker2',
          'test/worker3',
        ]
      )
    end

    let(:params) do
      {
        'test/worker2' => {
          foo: 'a',
          bar: 'b'
        },
        'test/worker3' => {
          foo: 'x',
          bar: 'y'
        }
      }
    end

    let(:concurrency) do
      {
        'test/worker2' => 42,
        'test/worker3' => 10
      }
    end

    subject do
      described_class.new(
        workers:     workers,
        params:      params,
        concurrency: concurrency
      )
    end

    context "when the other object is a #{described_class}" do
      context "and it has the same #workers, #params, and #concurrency values" do
        let(:other) do
          described_class.new(
            workers:     workers,
            params:      params,
            concurrency: concurrency
          )
        end

        it "must return true" do
          expect(subject.eql?(other)).to be(true)
        end
      end

      context "but the other object's #workers is different" do
        let(:other_workers) do
          described_class::Workers.new(
            Set[
              'test/worker1',
              'test/worker3',
            ]
          )
        end

        let(:other) do
          described_class.new(
            workers:     other_workers,
            params:      params,
            concurrency: concurrency
          )
        end

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other object's #params is different" do
        let(:other_params) do
          {
            'test/worker2' => {
              bar: 'b'
            },
            'test/worker3' => {
              foo: 'x'
            }
          }
        end

        let(:other) do
          described_class.new(
            workers:     workers,
            params:      other_params,
            concurrency: concurrency
          )
        end

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other object's #concurrency is different" do
        let(:other_concurrency) do
          {
            'test/worker2' => 1,
            'test/worker3' => 2
          }
        end

        let(:other) do
          described_class.new(
            workers:     workers,
            params:      params,
            concurrency: other_concurrency
          )
        end

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "but the other object has different #workers, #params, and #concurrency" do
        let(:other_workers) do
          described_class::Workers.new(
            Set[
              'test/worker1',
              'test/worker3',
            ]
          )
        end

        let(:other_params) do
          {
            'test/worker2' => {
              bar: 'b'
            },
            'test/worker3' => {
              foo: 'x'
            }
          }
        end

        let(:other_concurrency) do
          {
            'test/worker2' => 1,
            'test/worker3' => 2
          }
        end

        let(:other) do
          described_class.new(
            workers:     other_workers,
            params:      other_params,
            concurrency: other_concurrency
          )
        end

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end

      context "when given another kind of object" do
        let(:other) { Object.new }

        it "must return false" do
          expect(subject.eql?(other)).to be(false)
        end
      end
    end
  end

  describe "#to_yaml" do
    let(:expected_yml) { File.join(fixtures_dir,'with_params_and_workers.yml') }

    subject { described_class.load(expected_yml) }

    it "must convert Config into YAML string" do
      expect(subject.to_yaml).to eq(File.read(expected_yml))
    end
  end

  describe "#save" do
    subject { described_class.default }

    let(:tempdir) { Dir.mktmpdir('test-ronin-recon-config-save') }
    let(:path)    { File.join(tempdir, 'test-config.yml') }

    it "must write Config converted to YAML into a file" do
      subject.save(path)

      expect(File.read(path)).to eq(subject.to_yaml)
    end
  end
end
