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

require_relative '../../web_worker'

require 'ronin/web/spider'

module Ronin
  module Recon
    module Web
      #
      # A recon worker that spiders a website.
      #
      class Spider < WebWorker

        register 'web/spider'

        summary 'Spiders a website and finds every URL'

        description <<~DESC
          Spiders a website and finds every URL.

          * Visits every `a`, `iframe`, `frame`, `link`, and `script` URL.
          * Extracts paths from JavaScript.
          * Extracts URLs from JavaScript.
        DESC

        accepts Website
        outputs URL

        param :limit, Integer, desc: 'The maximum number of pages to visit.'

        param :max_depth, Integer, desc: 'The maximum link depth to follow.'

        param :delay, Integer, desc: 'The number of seconds to pause between each request.'

        param :open_timeout, Integer, desc: 'Optional open connection timeout.'

        param :read_timeout, Integer, desc: 'Optional read timeout.'

        param :ssl_timeout, Integer, desc: 'Optional SSL connection timeout.'

        param :continue_timeout, Integer, desc: 'Optional continue timeout.'

        param :keep_alive_timeout, Integer, desc: 'Optional `Keep-Alive` timeout.'

        param :proxy, URI, desc: 'The proxy information to use.'

        param :referer, String, desc: 'The `Referer` URL to send with each request.'

        param :user_agent, String, desc: 'The `User-Agent` string to send with each requests.'

        param :robots, Boolean, desc: 'Specifies whether `robots.txt` should be honored.'

        #
        # Spiders a website and yields every spidered URL.
        #
        # @param [Values::Website] website
        #   The website value to start spidering.
        #
        # @yield [url]
        #   Every spidered URL will be yielded.
        #
        # @yieldparam [Values::URL] url
        #   A URL visited by the spider.
        #
        def process(website)
          base_uri = website.to_uri

          Ronin::Web::Spider.site(base_uri, **agent_kwargs) do |agent|
            agent.every_page do |page|
              if VALID_STATUS_CODES.include?(page.code)
                yield URL.new(page.url, status:  page.code,
                                        headers: page.headers,
                                        body:    page.body)
              end
            end

            agent.every_javascript_url_string do |url,page|
              uri = URI.parse(url)

              case uri
              when URI::HTTP
                agent.enqueue(uri)
              end
            rescue URI::InvalidURIError
              # ignore invalid URIs
            end

            agent.every_javascript_path_string do |path,page|
              if (uri = page.to_absolute(path))
                case uri
                when URI::HTTP
                  agent.enqueue(uri)
                end
              end
            end
          end
        end

        #
        # Returns Hash based on the params
        #
        def agent_kwargs
          params.slice(:limit, :max_depth, :delay, :open_timeout, :read_timeout, :ssl_timeout, :continue_timeout, :keep_alive_timeout, :proxy, :referer, :user_agent, :robots)
        end

      end
    end
  end
end
