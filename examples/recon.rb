#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'ronin/recon/engine'

domain = Ronin::Recon::Values::Domain.new('example.com')

Ronin::Recon::Engine.run([domain], max_depth: 3) do |engine|
  engine.on(:value) do |value,parent|
    case value
    when Ronin::Recon::Values::Domain
      puts ">>> Found new domain #{value} for #{parent}"
    when Ronin::Recon::Values::Nameserver
      puts ">>> Found new nameserver #{value} for #{parent}"
    when Ronin::Recon::Values::Mailserver
      puts ">>> Found new mailserver #{value} for #{parent}"
    when Ronin::Recon::Values::Host
      puts ">>> Found new host #{value} for #{parent}"
    when Ronin::Recon::Values::IP
      puts ">>> Found new IP address #{value} for #{parent}"
    end
  end
end
