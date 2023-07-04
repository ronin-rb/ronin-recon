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

require 'ronin/core/output_formats'
require 'ronin/recon/output_formats/dir'
require 'ronin/recon/output_formats/dot'

module Ronin
  module Recon
    #
    # Contains the supported output formats for saving {Ronin::Recon::Values}
    # object to output files.
    #
    module OutputFormats
      include Core::OutputFormats

      register :txt,    '.txt',    TXT
      register :csv,    '.csv',    CSV
      register :json,   '.json',   JSON
      register :ndjson, '.ndjson', NDJSON
      register :dir,    '',        Dir
      register :dot,    '.dot',    Dot
    end
  end
end
