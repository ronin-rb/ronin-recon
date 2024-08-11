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
require_relative 'spider'
require 'ronin/support/text/patterns'

module Ronin
  module Recon
    module Web
      #
      # A recon worker that returns email addresses found on website.
      #
      class EmailAddresses < WebWorker

        register 'web/email_addresses'

        summary 'Extracts emails from a website'

        description <<~DESC
          Extracts all emails from a website.
        DESC

        accepts URL
        outputs EmailAddress
        intensity :passive

        #
        # Extract email addresses found in the pages body.
        #
        # @param [Values::URL] url
        #   The URL of the page to extract email addresses from.
        #
        # @yield [email]
        #   Each email address found on the page will be yielded.
        #
        # @yieldparam [Values::EmailAddress] email
        #   Email address found on the page.
        #
        def process(url)
          if (body = url.body)
            if body.encoding == Encoding::ASCII_8BIT
              # forcibly convert and scrub binary data into UTF-8 data
              body = body.dup
              body.force_encoding(Encoding::UTF_8)
              body.scrub!
            end

            body.scan(Support::Text::Patterns::EMAIL_ADDRESS) do |email|
              yield EmailAddress.new(email)
            end
          end
        end

      end
    end
  end
end
