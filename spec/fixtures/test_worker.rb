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

      intensity :passive

      def process(value)
        # no-op
      end

    end
  end
end
