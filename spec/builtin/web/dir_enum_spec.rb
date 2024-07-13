require 'spec_helper'
require 'ronin/recon/builtin/web/dir_enum'

require 'sinatra/base'
require 'webmock/rspec'

describe Ronin::Recon::Web::DirEnum do
  it "must inherit from Ronin::Recon::WebWorker" do
    expect(described_class).to be < Ronin::Recon::WebWorker
  end

  describe "accepts" do
    subject { described_class.accepts }

    it "must accept Website values" do
      expect(subject).to include(Ronin::Recon::Values::Website)
    end
  end

  describe "outputs" do
    subject { described_class.outputs }

    it "must output URL values" do
      expect(subject).to include(Ronin::Recon::Values::URL)
    end
  end

  describe "intensity" do
    subject { described_class.intensity }

    it "must have the intensity level of :aggressive" do
      expect(subject).to be(:aggressive)
    end
  end

  describe "params" do
    subject { described_class }

    it "must define a concurrency param" do
      expect(subject.params[:concurrency]).to_not be_nil
      expect(subject.params[:concurrency].type).to be_kind_of(Ronin::Core::Params::Types::Integer)
      expect(subject.params[:concurrency].default).to be(10)
      expect(subject.params[:concurrency].desc).to eq('Sets the number of async tasks')
    end

    it "must define a wordlist param" do
      expect(subject.params[:wordlist]).to_not be_nil
      expect(subject.params[:wordlist].type).to be_kind_of(Ronin::Core::Params::Types::String)
      expect(subject.params[:wordlist].desc).to eq('Optional directory wordlist to use')
    end
  end

  module TestWebDirEnum
    class App < Sinatra::Base

      set :host, 'example.com'
      set :port, 80

      get '/' do
        halt 200
      end

      get '/admin' do
        halt 200
      end

      get '/downloads' do
        halt 200
      end

      get '/secret' do
        halt 200
      end
    end
  end

  let(:host) { 'example.com' }
  let(:app)  { TestWebDirEnum::App }

  before do
    stub_request(:head, /#{Regexp.escape(host)}/).to_rack(app)
  end

  after(:all) { WebMock.allow_net_connect! }

  let(:fixtures_dir)  { File.join(__dir__,'fixtures') }
  let(:wordlist_path) { File.join(fixtures_dir,'dir_enum_wordlist.txt') }

  subject do
    described_class.new(params: {wordlist: wordlist_path})
  end

  describe "#process" do
    let(:website) { Ronin::Recon::Values::Website.http(host) }

    it "must bruteforce directories by sending HTTP HEAD requests using the default wordlist" do
      yielded_values = []

      Async do
        subject.process(website) do |url|
          yielded_values << url
        end
      end

      expect(yielded_values.length).to eq(3)
      expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[0].uri).to eq(URI('http://example.com/admin'))
      expect(yielded_values[1]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[1].uri).to eq(URI('http://example.com/downloads'))
      expect(yielded_values[2]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[2].uri).to eq(URI('http://example.com/secret'))
    end

    # Valid HTTP status codes
    [
      200, # OK
      201, # Created
      202, # Accepted
      203, # Non-Authoritative Information
      204, # No Content
      205, # Reset Content
      206, # Partial Content
      207, # Multi-Status
      208, # Already Reported
      226, # IM Used
      405, # Method Not Allowed
      409, # Conflict
      415, # Unsupported Media Type
      422, # Unprocessable Content
      423, # Locked
      424, # Failed Dependency
      451, # Unavailable For Legal Reasons
      500  # Internal Server Error
    ].each do |status_code|
      context "when a request returns #{status_code} status" do
        let(:app) do
          Class.new(Sinatra::Base) do |app|
            app.set :host, 'example.com'
            app.set :port, 80

            app.get("/admin") do
              halt status_code
            end
          end
        end

        it "must yield a URL value for the directory" do
          yielded_values = []

          Async do
            subject.process(website) do |url|
              yielded_values << url
            end
          end

          expect(yielded_values.length).to eq(1)
          expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[0].uri).to eq(URI('http://example.com/admin'))
        end
      end
    end

    # Invalid HTTP status codes
    [
      # 100, # Continue
      101, # Switching Protocols
      # 102, # Processing
      # 103, # Early Hints
      300, # Multiple Choices
      301, # Moved Permanently (Redirect)
      302, # Found (Redirect)
      303, # See Other (Redirect)
      304, # Not Modified (Redirect)
      307, # Temporary Redirect
      308, # Permanent Redirect
      400, # Bad Request
      401, # Unauthorized
      402, # Payment Required
      403, # Forbidden
      404, # Not Found
      406, # Not Acceptable
      407, # Proxy Authentication Required
      408, # Request Timeout
      410, # Gone
      411, # Length Required
      412, # Precondition Failed
      413, # Content Too Large
      414, # URI Too Long
      416, # Range Not Satisfiable
      417, # Expectation Failed
      418, # I'm a teapot
      421, # Misdirected Request
      425, # Too Early
      426, # Upgrade Required
      428, # Precondition Required
      429, # Too Many Requests
      431, # Request Header Fields Too Large
      501, # Not Implemented
      502, # Bad Gateway
      503, # Service Unavailable
      504, # Gateway Timeout
      505, # HTTP Version Not Supported
      506, # Variant Also Negotiates
      507, # Insufficient Storage
      508, # Loop Detected
      510, # Not Extended
      511  # Network Authentication Required
    ].each do |status_code|
      context "when a request returns #{status_code} status" do
        let(:app) do
          Class.new(Sinatra::Base) do |app|
            app.set :host, 'example.com'
            app.set :port, 80

            app.get("/admin") do
              halt status_code
            end
          end
        end

        it "must not yield a URL value for the directory" do
          yielded_values = []

          Async do
            subject.process(website) do |url|
              yielded_values << url
            end
          end

          expect(yielded_values).to be_empty
        end
      end
    end
  end
end
