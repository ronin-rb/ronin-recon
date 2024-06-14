require 'spec_helper'
require 'ronin/recon/cli/commands/new'

require 'tmpdir'

describe Ronin::Recon::CLI::Commands::New do
  describe "options" do
    before { subject.option_parser.parse(argv) }

    context "when given the '--type TYPE' option" do
      let(:type) { :dns }
      let(:argv) { ['--type', type.to_s] }

      it "must set #worker_type" do
        expect(subject.worker_type).to eq(
          described_class::WORKER_TYPES.fetch(type)
        )
      end
    end

    context "when given the '--accepts VALUE_TYPE' option" do
      let(:value1) { :domain }
      let(:value2) { :host }
      let(:argv)   { ['--accepts', value1.to_s, '--accepts', value2.to_s] }

      it "must append the value types to #accepts" do
        expect(subject.accepts).to eq(
          Set[
            described_class::VALUE_TYPES.fetch(value1),
            described_class::VALUE_TYPES.fetch(value2)
          ]
        )
      end
    end

    context "when given the '--outputs VALUE_TYPE' option" do
      let(:value1) { :domain }
      let(:value2) { :host }
      let(:argv)   { ['--outputs', value1.to_s, '--outputs', value2.to_s] }

      it "must append the value types to #outputs" do
        expect(subject.outputs).to eq(
          Set[
            described_class::VALUE_TYPES.fetch(value1),
            described_class::VALUE_TYPES.fetch(value2)
          ]
        )
      end
    end

    describe "when given the '--intensity LEVEL' option" do
      let(:level) { :aggressive }
      let(:argv)  { ['--intensity', level.to_s] }

      it "must set #intensity" do
        expect(subject.intensity).to eq(level)
      end
    end
  end

  describe "#run" do
    let(:tempdir) { Dir.mktmpdir('test-ronin-recon-new') }
    let(:path)    { File.join(tempdir,'test_worker.rb') }

    let(:default_author_name)  { 'John Smith' }
    let(:default_author_email) { 'john.smith@example.com' }

    let(:argv) { [] }

    before do
      allow(Ronin::Core::CLI::Generator::Options::Author).to receive(:default_name).and_return(default_author_name)
      allow(Ronin::Core::CLI::Generator::Options::Author).to receive(:default_email).and_return(default_author_email)

      subject.option_parser.parse(argv)
      subject.run(path)
    end

    it "must generate a new file containing a new Ronin::Recon::Worker class" do
      expect(File.read(path)).to eq(
        <<~RUBY
          #!/usr/bin/env -S ronin-recon test -f

          require 'ronin/recon/worker'

          module Ronin
            module Recon
              class TestWorker < Worker

                register 'test_worker'

                author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                summary "FIX ME"
                description <<~DESC
                  FIX ME
                DESC
                # references [
                #   "https://...",
                #   "https://..."
                # ]

                accepts FIXME
                outputs FIXME

                def process(value)
                  # ...
                end

              end
            end
          end
        RUBY
      )
    end

    it "must make the file executable" do
      expect(File.executable?(path)).to be(true)
    end

    context "when the parent directory does not exist yet" do
      let(:path) { File.join(tempdir,'does_not_exist_yet','test_worker.rb') }

      it "must create the parent directory" do
        expect(File.directory?(File.dirname(path))).to be(true)
      end
    end

    context "when the user's name cannot be inferred from git or $USERNAME" do
      let(:default_author_name)  { nil }
      let(:default_author_email) { nil }

      it "must add a boilerplate `author` metadata attribute" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author "FIX ME", email: "FIXME@example.com"
                  summary "FIX ME"
                  description <<~DESC
                    FIX ME
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts FIXME
                  outputs FIXME

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end

    context "when the '--author NAME' option is given" do
      let(:name) { 'Bob' }
      let(:argv) { ['--author', name] }

      it "must override the author name in the `author ...` metadata attribute with the '--author' name" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{name.inspect}, email: #{default_author_email.inspect}
                  summary "FIX ME"
                  description <<~DESC
                    FIX ME
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts FIXME
                  outputs FIXME

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end

      context "and when the '--author-email EMAIL' option is given" do
        let(:email) { 'bob@example.com' }
        let(:argv)  { super() + ['--author-email', email] }

        it "must override the author email in the `author ...` metadata attribute with the '--author-email' email" do
          expect(File.read(path)).to eq(
            <<~RUBY
              #!/usr/bin/env -S ronin-recon test -f

              require 'ronin/recon/worker'

              module Ronin
                module Recon
                  class TestWorker < Worker

                    register 'test_worker'

                    author #{name.inspect}, email: #{email.inspect}
                    summary "FIX ME"
                    description <<~DESC
                      FIX ME
                    DESC
                    # references [
                    #   "https://...",
                    #   "https://..."
                    # ]

                    accepts FIXME
                    outputs FIXME

                    def process(value)
                      # ...
                    end

                  end
                end
              end
            RUBY
          )
        end
      end
    end

    context "when the '--summary TEXT' option is given" do
      let(:summary) { "Foo bar baz" }
      let(:argv)    { ['--summary', summary] }

      it "must fill in the `summary ...` metadata attribute with the '--summary' text" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                  summary #{summary.inspect}
                  description <<~DESC
                    FIX ME
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts FIXME
                  outputs FIXME

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end

    context "when the '--description TEXT' option is given" do
      let(:description) { "Foo bar baz." }
      let(:argv)        { ['--description', description] }

      it "must fill in the `description ...` metadata attribute with the '--description' text" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                  summary "FIX ME"
                  description <<~DESC
                    #{description}
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts FIXME
                  outputs FIXME

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end

    context "when the '--reference URL' option is given" do
      let(:url1) { 'https://example.com/reference1' }
      let(:url2) { 'https://example.com/reference2' }
      let(:argv) do
        ['--reference', url1, '--reference', url2]
      end

      it "must fill in the `references [...]` metadata attribute containing the '--reference' URLs" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                  summary "FIX ME"
                  description <<~DESC
                    FIX ME
                  DESC
                  references [
                    #{url1.inspect},
                    #{url2.inspect}
                  ]

                  accepts FIXME
                  outputs FIXME

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end

    context "when the '--accepts VALUE_TYPE' option is given" do
      let(:value_type1)  { :domain }
      let(:value_class1) { 'Domain' }
      let(:value_type2)  { :host }
      let(:value_class2) { 'Host' }
      let(:argv) do
        ['--accepts', value_type1.to_s, '--accepts', value_type2.to_s]
      end

      it "must set the `accepts ...` metadata attribute in the worker class with the '--accepts' value classes" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                  summary "FIX ME"
                  description <<~DESC
                    FIX ME
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts #{value_class1}, #{value_class2}
                  outputs FIXME

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end

    context "when the '--outputs VALUE_TYPE' option is given" do
      let(:value_type1)  { :domain }
      let(:value_class1) { 'Domain' }
      let(:value_type2)  { :host }
      let(:value_class2) { 'Host' }
      let(:argv) do
        ['--outputs', value_type1.to_s, '--outputs', value_type2.to_s]
      end

      it "must set the `outputs ...` metadata attribute in the worker class with the '--outputs' value classes" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                  summary "FIX ME"
                  description <<~DESC
                    FIX ME
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts FIXME
                  outputs #{value_class1}, #{value_class2}

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end

    context "when the '--intensity LEVEL' option is given" do
      let(:intensity) { :aggressive }
      let(:argv)      { ['--intensity', intensity.to_s] }

      it "must add the `intensity :level` metadata attribute to the worker class using the '--intensity' level" do
        expect(File.read(path)).to eq(
          <<~RUBY
            #!/usr/bin/env -S ronin-recon test -f

            require 'ronin/recon/worker'

            module Ronin
              module Recon
                class TestWorker < Worker

                  register 'test_worker'

                  author #{subject.author_name.inspect}, email: #{subject.author_email.inspect}
                  summary "FIX ME"
                  description <<~DESC
                    FIX ME
                  DESC
                  # references [
                  #   "https://...",
                  #   "https://..."
                  # ]

                  accepts FIXME
                  outputs FIXME
                  intensity #{intensity.inspect}

                  def process(value)
                    # ...
                  end

                end
              end
            end
          RUBY
        )
      end
    end
  end
end
