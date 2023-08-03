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
require 'ronin/recon/builtin/web/spider'
require 'ronin/support/text/patterns'

module Ronin
  module Recon
    module Web
      #
      # A recon worker that returns email addresses found on website.
      #
      class EmailAddresses < WebWorker

        register 'web/email_addresses'

        accepts URL

        summary 'Extracts emails from a website'

        description <<~DESC
          Extracts all emails from a website.
        DESC

        #
        # Extract email addresses found in the pages body.
        #
        # @param [Values::URL]
        #  The URL of the page to extract email addresses from.
        #
        # @yield [url]
        #
        # @yieldparam [Values::EmailAddress] email
        #   Email address found on the page.
        #
        def process(url)
          return nil unless url.body

          email_pattern = Ronin::Support::Text::Patterns::EMAIL_ADDRESS

          url.body.force_encoding(Encoding::UTF_8).scan(email_pattern) do |email|
            yield EmailAddress.new(email)
          end
        end

      end
    end
  end
end
