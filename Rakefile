# frozen_string_literal: true

begin
  require 'bundler'
rescue LoadError => e
  warn e.message
  warn "Run `gem install bundler` to install Bundler"
  exit(-1)
end

begin
  Bundler.setup(:development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'

require 'rubygems/tasks'
Gem::Tasks.new(sign: {checksum: true, pgp: true})

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

namespace :spec do
  RSpec::Core::RakeTask.new(:network) do |t|
    t.rspec_opts = '--tag network'
  end
end

task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
task :docs => :yard

require 'kramdown/man/task'
Kramdown::Man::Task.new

directory 'data/wordlists'

file 'data/wordlists/subdomains-1000.txt' => 'data/wordlists' do
  sh 'wget -O data/wordlists/subdomains-1000.txt https://raw.githubusercontent.com/rbsec/dnscan/master/subdomains-1000.txt'
end

file 'data/wordlists/subdomains-1000.txt.gz' => 'data/wordlists/subdomains-1000.txt' do
  sh 'gzip -f data/wordlists/subdomains-1000.txt'
end

file 'data/wordlists/raft-small-directories.txt' => 'data/wordlists' do
  sh 'wget -O data/wordlists/raft-small-directories.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/raft-small-directories.txt'
end

file 'data/wordlists/raft-small-directories.txt.gz' => 'data/wordlists/raft-small-directories.txt' do
  sh 'gzip -f data/wordlists/raft-small-directories.txt'
end

desc 'Generate built-in wordlists'
task :wordlists => %w[
  data/wordlists/subdomains-1000.txt.gz
  data/wordlists/raft-small-directories.txt.gz
]

require 'command_kit/completion/task'
CommandKit::Completion::Task.new(
  class_file:  'ronin/recon/cli',
  class_name:  'Ronin::Recon::CLI',
  input_file:  'data/completions/ronin-recon.yml',
  output_file: 'data/completions/ronin-recon'
)

task :setup => %w[wordlists man command_kit:completion]
