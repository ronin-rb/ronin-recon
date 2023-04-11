#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'ronin/recon/engine'

domain = Ronin::Recon::Values::Domain.new('github.com')

Ronin::Recon::Engine.run([domain], max_depth: 3) do |value,parent|
  case value
  when Ronin::Recon::Values::Domain
    puts "Found domain #{value} for #{parent}"
  when Ronin::Recon::Values::Nameserver
    puts "Found nameserver #{value} for #{parent}"
  when Ronin::Recon::Values::Mailserver
    puts "Found mailserver #{value} for #{parent}"
  when Ronin::Recon::Values::Host
    puts "Found host #{value} for #{parent}"
  when Ronin::Recon::Values::IP
    puts "Found IP address #{value} for #{parent}"
  end
end
