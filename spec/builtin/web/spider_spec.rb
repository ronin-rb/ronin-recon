require 'spec_helper'
require 'ronin/recon/builtin/web/spider'

require 'sinatra/base'
require 'webmock/rspec'
require 'uri'

describe Ronin::Recon::Web::Spider do
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

  module TestWebSpider
    class App < Sinatra::Base

      set :host, 'example.com'
      set :port, 80

      get '/' do
        <<~HTML
          <html>
            <body>
              <a href="/link1">link1</a>
              <a href="http://example.com/link2">link2</a>
              <a href="http://other.com/">should not go here</a>
            </body>
          </html>
        HTML
      end

      get '/link1' do
        <<~HTML
          <html>
            <body>
              <a href="../link3">link3</a>
            </body>
          </html>
        HTML
      end

      get '/link2' do
        <<~HTML
          <html>
            <body>got here</body>
          </html>
        HTML
      end

      get '/link3' do
        <<~HTML
          <html>
            <body>got here</body>
          </html>
        HTML
      end
    end
  end

  let(:host) { 'example.com' }
  let(:app)  { TestWebSpider::App }

  before do
    stub_request(:get, /#{Regexp.escape(host)}/).to_rack(app)
  end

  after(:all) { WebMock.allow_net_connect! }

  describe "#process" do
    let(:website) { Ronin::Recon::Values::Website.http(host) }

    it "must visit every link on the website and yield every URL value" do
      yielded_values = []

      Async do
        subject.process(website) do |url|
          yielded_values << url
        end
      end

      expect(yielded_values.length).to eq(4)
      expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[0].uri).to eq(URI('http://example.com/'))
      expect(yielded_values[1]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[1].uri).to eq(URI('http://example.com/link1'))
      expect(yielded_values[2]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[2].uri).to eq(URI('http://example.com/link2'))
      expect(yielded_values[3]).to be_kind_of(Ronin::Recon::Values::URL)
      expect(yielded_values[3].uri).to eq(URI('http://example.com/link3'))
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
      context "when a link returns a #{status_code} status" do
        let(:app) do
          Class.new(Sinatra::Base) do |app|
            app.set :host, 'example.com'
            app.set :port, 80

            app.get '/' do
              <<~HTML
                <html>
                  <body>
                    <a href="/link">link</a>
                  </body>
                </html>
              HTML
            end

            app.get("/link") do
              halt status_code
            end
          end
        end

        it "must yield a URL value for the link" do
          yielded_values = []

          Async do
            subject.process(website) do |url|
              yielded_values << url
            end
          end

          expect(yielded_values.length).to eq(2)
          expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[0].uri).to eq(URI('http://example.com/'))
          expect(yielded_values[1]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[1].uri).to eq(URI('http://example.com/link'))
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
      context "when a link returns a #{status_code} status" do
        let(:app) do
          Class.new(Sinatra::Base) do |app|
            app.set :host, 'example.com'
            app.set :port, 80

            app.get '/' do
              <<~HTML
                <html>
                  <body>
                    <a href="/link">link</a>
                  </body>
                </html>
              HTML
            end

            app.get("/link") do
              halt status_code
            end
          end
        end

        it "must not yield a URL value for the link" do
          yielded_values = []

          Async do
            subject.process(website) do |url|
              yielded_values << url
            end
          end

          expect(yielded_values.length).to eq(1)
          expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[0].uri).to eq(URI('http://example.com/'))
        end
      end
    end

    context "when a page has JavaScript" do
      context "and it contains URL strings" do
        module TestWebSpider
          class AppWithURLsInJavaScript < Sinatra::Base

            set :host, 'example.com'
            set :port, 80

            get '/' do
              <<~HTML
                <html>
                  <body>
                    <script type="text/javascript">
                      var url1 = "http://example.com/link1";
                      var url2 = "http://example.com/does/not/exist";
                      var url3 = "http://other.com/";
                      var url4 = "http://example.com/link2";
                    </script>
                  </body>
                </html>
              HTML
            end

            get '/link1' do
              <<~HTML
                <html>
                  <body>got here</body>
                </html>
              HTML
            end

            get '/link2' do
              <<~HTML
                <html>
                  <body>got here</body>
                </html>
              HTML
            end
          end
        end

        let(:app) { TestWebSpider::AppWithURLsInJavaScript }

        it "must attempt to visit the URL strings within the JavaScript" do
          yielded_values = []

          Async do
            subject.process(website) do |url|
              yielded_values << url
            end
          end

          expect(yielded_values.length).to eq(3)
          expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[0].uri).to eq(URI('http://example.com/'))
          expect(yielded_values[1]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[1].uri).to eq(URI('http://example.com/link1'))
          expect(yielded_values[2]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[2].uri).to eq(URI('http://example.com/link2'))
        end
      end
    end

    context "when a page has JavaScript" do
      context "and it contains path strings" do
        module TestWebSpider
          class AppWithURLsInJavaScript < Sinatra::Base

            set :host, 'example.com'
            set :port, 80

            get '/' do
              <<~HTML
                <html>
                  <body>
                    <script type="text/javascript">
                      var url1 = "/link1";
                      var url2 = "/does/not/exist";
                      var url3 = "../link2";
                    </script>
                  </body>
                </html>
              HTML
            end

            get '/link1' do
              <<~HTML
                <html>
                  <body>got here</body>
                </html>
              HTML
            end

            get '/link2' do
              <<~HTML
                <html>
                  <body>got here</body>
                </html>
              HTML
            end
          end
        end

        let(:app) { TestWebSpider::AppWithURLsInJavaScript }

        it "must attempt to visit the path strings within the JavaScript" do
          yielded_values = []

          Async do
            subject.process(website) do |url|
              yielded_values << url
            end
          end

          expect(yielded_values.length).to eq(3)
          expect(yielded_values[0]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[0].uri).to eq(URI('http://example.com/'))
          expect(yielded_values[1]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[1].uri).to eq(URI('http://example.com/link1'))
          expect(yielded_values[2]).to be_kind_of(Ronin::Recon::Values::URL)
          expect(yielded_values[2].uri).to eq(URI('http://example.com/link2'))
        end
      end
    end
  end

  describe "#process", :network do
    before(:all) { WebMock.allow_net_connect! }

    context "when there are URLs in the website" do
      let(:website) do
        Ronin::Recon::Values::Website.http("testphp.vulnweb.com")
      end

      let(:expected_uris) do
        %w[
          http://testphp.vulnweb.com/
          http://testphp.vulnweb.com/index.php
          http://testphp.vulnweb.com/categories.php
          http://testphp.vulnweb.com/artists.php
          http://testphp.vulnweb.com/disclaimer.php
          http://testphp.vulnweb.com/cart.php
          http://testphp.vulnweb.com/guestbook.php
          http://testphp.vulnweb.com/AJAX/index.php
          http://testphp.vulnweb.com/login.php
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/
          http://testphp.vulnweb.com/hpp/
          http://testphp.vulnweb.com/style.css
          http://testphp.vulnweb.com/listproducts.php?cat=1
          http://testphp.vulnweb.com/listproducts.php?cat=2
          http://testphp.vulnweb.com/listproducts.php?cat=3
          http://testphp.vulnweb.com/listproducts.php?cat=4
          http://testphp.vulnweb.com/artists.php?artist=1
          http://testphp.vulnweb.com/artists.php?artist=2
          http://testphp.vulnweb.com/artists.php?artist=3
          http://testphp.vulnweb.com/AJAX/showxml.php
          http://testphp.vulnweb.com/AJAX/styles.css
          http://testphp.vulnweb.com/signup.php
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/Details/network-attached-storage-dlink/1/
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/Details/web-camera-a4tech/2/
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/Details/color-printer/3/
          http://testphp.vulnweb.com/hpp/?pp=12
          http://testphp.vulnweb.com/product.php?pic=1
          http://testphp.vulnweb.com/showimage.php?file=./pictures/1.jpg
          http://testphp.vulnweb.com/product.php?pic=2
          http://testphp.vulnweb.com/showimage.php?file=./pictures/2.jpg
          http://testphp.vulnweb.com/product.php?pic=3
          http://testphp.vulnweb.com/showimage.php?file=./pictures/3.jpg
          http://testphp.vulnweb.com/product.php?pic=4
          http://testphp.vulnweb.com/showimage.php?file=./pictures/4.jpg
          http://testphp.vulnweb.com/product.php?pic=5
          http://testphp.vulnweb.com/showimage.php?file=./pictures/5.jpg
          http://testphp.vulnweb.com/product.php?pic=7
          http://testphp.vulnweb.com/showimage.php?file=./pictures/7.jpg
          http://testphp.vulnweb.com/product.php?pic=6
          http://testphp.vulnweb.com/showimage.php?file=./pictures/6.jpg
          http://testphp.vulnweb.com/listproducts.php?artist=1
          http://testphp.vulnweb.com/listproducts.php?artist=2
          http://testphp.vulnweb.com/listproducts.php?artist=3
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/BuyProduct-1/
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/RateProduct-1.html
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/BuyProduct-2/
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/RateProduct-2.html
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/BuyProduct-3/
          http://testphp.vulnweb.com/Mod_Rewrite_Shop/RateProduct-3.html
          http://testphp.vulnweb.com/hpp/params.php?p=valid&pp=12
        ]
      end

      it "must yield URL" do
        yielded_values = []

        subject.process(website) do |value|
          yielded_values << value
        end

        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::URL))
        expect(yielded_values.map(&:uri).map(&:to_s)).to match_array(expected_uris)
        expect(yielded_values.map(&:status)).to all(eq(200))
      end
    end

    context "when there are no URLs in the website" do
      let(:website) do
        Ronin::Recon::Values::Website.https("www.foo.invalid",443)
      end

      it "must not yield anything" do
        expect { |b|
          Async do
            subject.process(website,&b)
          end
        }.not_to yield_control
      end
    end
  end
end
