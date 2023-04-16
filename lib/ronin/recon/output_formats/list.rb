require 'ronin/recon/output_format'

require 'set'

module Ronin
  module Recon
    module OutputFormats
      #
      # Represents a plain-text list of discovered values.
      #
      class List < OutputFormat

        # The set of previously seen values.
        #
        # @return [Set<Value>]
        attr_reader :values

        #
        # Initializes the list output format.
        #
        # @param [IO] io
        #   The IO stream to write to.
        #
        def initialize(io)
          super(io)

          @values = Set.new
        end

        #
        # Appends a value to the list output stream.
        #
        # @param [Value] value
        #   The value to append.
        # 
        # @return [self]
        #
        def write(value,parent)
          if @values.add?(value)
            @io.puts(value)
          end
        end

      end
    end
  end
end
