require 'ronin/recon/output_format'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a plain-text list of discovered values.
      #
      class List < OutputFormat

        #
        # Appends a value to the list output stream.
        #
        # @param [Value] value
        #   The value to append.
        # 
        # @return [self]
        #
        def write(value,parent)
          @io.puts(value)
        end

      end
    end
  end
end
