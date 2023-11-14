# frozen_string_literal: true
#
# ronin-recon - A micro-framework and tool for performing reconnaissance.
#
# Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)
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

require 'ronin/recon/web_worker'
require 'ronin/recon/root'

require 'wordlist'
require 'uri'
require 'async/queue'
require 'async/http/internet/instance'

module Ronin
  module Recon
    module Web
      #
      # A recon worker that discovers HTTP directories.
      #
      class DirEnum < WebWorker

        DEFAULT_WORDLIST = File.join(WORDLISTS_DIR, 'combined_directories.txt.gz')

        register 'web/dir_enum'

        accepts Website
        outputs URL

        summary 'Discovers HTTP directories for a website'

        description <<~DESC
          Discovers hidden directories on a website by sending HTTP HEAD
          requests using a wordlist of common web directory names.
        DESC

        intensity :intensive

        param :concurrency, Integer, default: 10,
                                     desc:    'Sets the number of async tasks'

        param :wordlist, String, desc: 'Optional directory wordlist to use'

        #
        # Discovers HTTP directories for a given website.
        #
        # @param [Values::Website] website
        #   The website to recon.
        #
        # @yield [url]
        #   Every discovered directory will be passed to the block as a URL.
        #
        # @yieldparam [Values::URL] url
        #   A URL representing an exposed directory.
        #
        def process(website)
          wordlist = Wordlist.open(params[:wordlist] || DEFAULT_WORDLIST)
          queue    = Async::LimitedQueue.new(params[:concurrency])
          base_url = website.to_s

          Async do |task|
            task.async do
              # feed the queue with the wordlist
              wordlist.each { |name| queue << name }

              # send stop messages for each sub-task
              params[:concurrency].times { queue << nil }
            end

            # spawn the sub-tasks
            params[:concurrency].times do
              task.async do
                http = Async::HTTP::Internet.instance

                while (dir = queue.dequeue)
                  path    = "/#{URI.encode_uri_component(dir)}"
                  url     = "#{base_url}#{path}"
                  retries = 0

                  begin
                    response = http.head(url)

                    if RESOURCE_STATUS_CODES.include?(response.status)
                      yield URL.new(url, status:  response.status,
                                         headers: response.to_h)
                    end
                  rescue Errno::ECONNREFUSED,
                         SocketError
                    task.stop
                  rescue StandardError
                    if retries > 3
                      next
                    else
                      retries += 1
                      sleep 1
                      retry
                    end
                  end
                end
              end
            end
          end
        end

      end
    end
  end
end
