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

require 'ronin/recon/registry'
require 'ronin/recon/values'
require 'ronin/core/metadata/id'
require 'ronin/core/metadata/authors'
require 'ronin/core/metadata/summary'
require 'ronin/core/metadata/description'
require 'ronin/core/metadata/references'
require 'ronin/core/params/mixin'

module Ronin
  module Recon
    #
    # Base class for all recon workers.
    #
    # ## Philosophy
    #
    # Recon involves performing multiple strategies on input values
    # (ex: a domain) in order to produce discovered output values
    # (ex: sub-domains). These recon strategies can be defined as classes
    # which have a `process` method that accepts certiain input {Values value}
    # types and yield zero or more output {Values value types}.
    #
    # The {Worker} class defines three key parts:
    #
    # 1. Metadata - defines information about the recon worker.
    # 2. [Params] - optional user configurable parameters.
    # 3. {Worker#process process} - method which receives a {Values Value} class
    #
    # [Params]: https://ronin-rb.dev/docs/ronin-core/Ronin/Core/Params/Mixin.html
    #
    # ## Example
    #
    #     require 'ronin/recon/worker'
    #
    #     module Ronin
    #       module Recon
    #         module DNS
    #           class FooBar
    #
    #             register 'dns/foo_bar'
    #
    #             accepts Domain
    #
    #             summary 'My DNS recon technique'
    #             description <<~DESC
    #               This recon worker uses the foo-bar technique.
    #               Bla bla bla bla.
    #             DESC
    #             author 'John Smith', email: '...'
    #
    #             param :wordlist, String, desc: 'Optional wordlist to use'
    #
    #             def process(value)
    #               # ...
    #               yield Host.new(discovered_host_name)
    #               # ...
    #             end
    #
    #           end
    #         end
    #       end
    #     end
    #
    # ### register
    #
    # Registers the worker with {Recon}.
    #
    #     register 'dns/foo_bar'
    #
    # ### accepts
    #
    # Defines which {Values Value} types the worker accepts.
    #
    #     accepts Domain
    #
    # Available {Values Value} types are:
    #
    # * {Values::Domain Domain} - a domain name (ex: `example.com`).
    # * {Values::Host Host} - a host-name (ex: `www.example.com`).
    # * {Values::IP} - a single IP address (ex: `192.168.1.1').
    # * {Values::IPRange} - a CIDR IP range (ex: `192.168.1.1/24`).
    # * {Values::Mailserver} - represents a mailserver for a domain
    #   (ex: `smtp.google.com`).
    # * {Values::Nameserver} - represents a nameserver for a domain
    #   (ex: `ns1.google.com`).
    # * {Values::OpenPort} - represents a discovered open port on an IP address.
    # * {Values::URL} - represents a discovered URL
    #   (ex: `https://example.com/index.html`).
    # * {Values::Website} - represents a discovered website
    #   (ex: `https://example.com/`).
    # * {Values::Wildcard} - represent a wildcard host name
    #   (ex: `*.example.com`).
    #
    # **Note:** the recon worker may specify that it accepts multiple value
    # types:
    #
    #     accepts Domain, Host, IP
    #
    # ### summary
    #
    # Defines a short one-sentence description of the recon worker.
    #
    #     summary 'My DNS recon technique'
    #
    # ### description
    #
    # Defines a longer multi-paragraph description of the recon worker.
    #
    #     description <<~DESC
    #       This recon worker uses the foo-bar technique.
    #       Bla bla bla bla.
    #     DESC
    #
    # **Note:** that `<<~` heredoc, unlike the regular `<<` heredoc, removes
    # leading whitespace.
    #
    # ### author
    #
    # Add an author's name and additional information to the recon worker.
    #
    #     author 'John Smith'
    #
    #     author 'doctor_doom', email: '...', twitter: '...'
    #
    # ### param
    #
    # Defines a user configurable param. Params may have a type class, but
    # default to `String`. Params must have a one-line description.
    #
    #     param :str, desc: 'A basic string param'
    #
    #     param :feature_flag, Boolean, desc: 'A boolean param'
    #
    #     param :enum, Enum[:one, :two, :three],
    #                  desc: 'An enum param'
    #
    #     param :num1, Integer, desc: 'An integer param'
    #
    #     param :num2, Integer, default: 42,
    #                          desc: 'A param with a default value'
    #
    #     param :num3, Integer, default: ->{ rand(42) },
    #                           desc: 'A param with a dynamic default value'
    #
    #     param :float, Float, 'Floating point param'
    #
    #     param :url, URI, desc: 'URL param'
    #
    #     param :pattern, Regexp, desc: 'Regular Expression param'
    #
    # Params may then be accessed in instance methods using `params` Hash.
    #
    #     param :retries, Integer, default: 4,
    #                              desc:    'Number of retries'
    #
    #     def process(value)
    #       retry_count = 0
    #
    #       begin
    #         # ...
    #       rescue => error
    #         retry_count += 1
    #
    #         if retry_count < params[:retries]
    #           retry
    #         else
    #           raise(error)
    #         end
    #       end
    #     end
    #
    # @api public
    #
    class Worker

      include Core::Metadata::ID
      include Core::Metadata::Authors
      include Core::Metadata::Summary
      include Core::Metadata::Description
      include Core::Metadata::References
      include Core::Params::Mixin
      include Values

      #
      # Registers the recon worker with the given name.
      #
      # @param [String] worker_id
      #   The recon worker's `id`.
      #
      # @example
      #   require 'ronin/recon/worker'
      #
      #   module Ronin
      #     module Recon
      #       module DNS
      #         class SubdomainBruteforcer < Worker
      #
      #           register 'dns/subdomain_bruteforcer'
      #
      #         end
      #       end
      #     end
      #    end
      #
      # @api public
      #
      def self.register(worker_id)
        id(worker_id)
        Recon.register(worker_id,self)
      end

      #
      # Initializes the worker.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments.
      #
      def initialize(**kwargs)
        super(**kwargs)
      end

      #
      # Gets or sets the value class which the recon worker accepts.
      #
      # @param [Array<Class<Value>>] value_classes
      #   The optional new value class(es) to accept.
      #
      # @return [Array<Class<Value>>]
      #   the value class which the recon worker accepts.
      #
      # @raise [NotImplementedError]
      #   No value class was defined for the recon worker.
      #
      # @example define that the recon worker accepts IP addresses:
      #   accepts IP
      #
      def self.accepts(*value_classes)
        unless value_classes.empty?
          @accepts = value_classes
        else
          @accepts || if superclass < Worker
                        superclass.accepts
                      else
                        raise(NotImplementedError,"#{self} did not set accepts")
                      end
        end
      end

      #
      # Gets or sets the worker's default concurrency.
      #
      # @param [Integer, nil] new_concurrency
      #   The optional new concurrency to set.
      #
      # @return [Integer]
      #   The worker's concurrency. Defaults to `1` if not set.
      #
      # @example sets the recon worker's default concurrency:
      #   concurrency 3
      #
      def self.concurrency(new_concurrency=nil)
        if new_concurrency
          @concurrency = new_concurrency
        else
          @concurrency || if superclass < Worker
                            superclass.concurrency
                          else
                            1
                          end
        end
      end

      #
      # Initializes the worker and runs it with the single value.
      #
      # @param [Value] value
      #   The input value to process.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments to initialize the worker with.
      #
      # @note
      #   This method is mainly for testing workers and running them
      #   individually.
      #
      def self.run(value,**kwargs,&block)
        worker = new(**kwargs)

        Async do
          worker.process(value,&block)
        end
      end

      #
      # Calls the recon worker with the given input value.
      #
      # @param [Value] value
      #   The input value.
      #
      # @yield [new_value]
      #   The `call` method can then `yield` one or more newly discovered values
      #
      # @yieldparam [Value] new_value
      #   An newly discovered output value from the input value.
      #
      # @abstract
      #
      def process(value,&block)
        raise(NotImplementedError,"#{self} did not define a #process method")
      end

    end
  end
end
