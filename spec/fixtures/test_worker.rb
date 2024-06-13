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

      param :prefix, default: 'test',
                     desc:    'Example param'

      def process(value)
        prefix = params[:prefix]

        yield Host.new("#{prefix}1.#{value}")
        yield Host.new("#{prefix}2.#{value}")
      end

    end
  end
end
