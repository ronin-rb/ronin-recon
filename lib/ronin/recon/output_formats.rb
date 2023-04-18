require 'ronin/recon/output_formats/txt'
require 'ronin/recon/output_formats/csv'
require 'ronin/recon/output_formats/json'
require 'ronin/recon/output_formats/ndjson'
require 'ronin/recon/output_formats/dot'

module Ronin
  module Recon
    module OutputFormats
      # Mapping of output format names to output format classes.
      FORMATS = {
        txt:    TXT,
        csv:    CSV,
        json:   JSON,
        ndjson: NDJSON,
        dot:    Dot
      }

      # Mapping of file extensions to output format classes.
      FILE_EXTS = {
        '.txt'    => TXT,
        '.csv'    => CSV,
        '.json'   => JSON,
        '.ndjson' => NDJSON,
        '.dot'    => Dot
      }
    end
  end
end
