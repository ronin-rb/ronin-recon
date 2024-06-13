require 'ronin/recon/worker'

module Ronin
  module Recon
    class TestWorker < Worker

      register 'test_worker'

      summary 'Test worker'
      description <<~DESC
        This is a test worker.
      DESC
      author 'Postmodern', email: 'postmodern.mod3@gmail.com'

      accepts Domain
      outputs Host

      intensity :passive

      def process(value)
        yield Host.new("test1.#{value}")
        yield Host.new("test2.#{value}")
      end

    end
  end
end
