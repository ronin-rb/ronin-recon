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

require 'ronin/web/spider/git_archive'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a web archive directory that is backed by Git.
      #
      class GitArchive

        #
        # Initializes new Git repository.
        #
        # @param [String] root
        #   The path to the root directory.
        #
        def initialize(root)
          @git_archive = Ronin::Web::Spider::GitArchive.new(root)
          @git_archive.init unless @git_archive.git?
        end

        #
        # Writes a new URL to it's specific file in Git archive.
        #
        # @param [Value] value
        #   The value to write.
        #
        def <<(value)
          if Values::URL === value
            @git_archive.write(value.uri, value.body)
          end
        end

      end
    end
  end
end
