# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023-2024 Hal Brodigan (postmodern.mod3@gmail.com)
#
# ronin-recon is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-recon is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-recon.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/recon/worker'

require 'ronin/web/browser'

module Ronin
  module Recon
    module Web
      #
      # A recon worker that takes a screenshot of a page.
      #
      # @since 0.2.0
      #
      class Screenshot < Worker

        register 'web/screenshot'

        summary 'Visits a website and takes a screenshot of it'
        description <<~DESC
          Visits a website and takes a screenshot of it.
        DESC

        accepts URL
        outputs nil
        concurrency 1

        param :output_dir, String, required: true,
                                   desc:     'The directory you want to save the screenshot to.'

        param :format, Enum[:png, :jpg], required: true,
                                         default:  :png,
                                         desc:     'The screenshot format.'

        # The Web::Browser instance
        #
        # @return [Web::Browser]
        #
        # @api private
        attr_reader :browser

        #
        # Initializes the `web/screenshot` worker.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   Additional keyword arguments.
        #
        # @api private
        #
        def initialize(**kwargs)
          super(**kwargs)

          @browser = Ronin::Web::Browser.new
        end

        #
        # Visits a website and takes a screenshot of it.
        #
        # @param [Values::URL] url
        #   The URL of the website you want to screenshot.
        #
        def process(url)
          browser.go_to(url)

          path = path_for(browser.page.url)
          FileUtils.mkdir_p(File.dirname(path))

          browser.screenshot(path: path)
        end

        #
        # Generates the file path for a given URL.
        #
        # @param [String] url
        #   The given url.
        #
        # @return [String]
        #   The relative file path that represents the URL.
        #
        def path_for(url)
          page_url = URI(url)
          path     = File.join(params[:output_dir], page_url.host, page_url.request_uri)
          path << 'index' if path.end_with?('/')
          path << ".#{params[:format]}"
        end
      end
    end
  end
end
