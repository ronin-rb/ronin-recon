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
task :test    => :spec
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
task :docs => :yard

require 'kramdown/man/task'
Kramdown::Man::Task.new

file 'data/subdomains-1000.txt' do
  sh 'wget -O data/subdomains-1000.txt https://raw.githubusercontent.com/rbsec/dnscan/master/subdomains-1000.txt'
end

file 'data/subdomains-1000.txt.gz' => 'data/subdomains-1000.txt' do
  sh 'gzip -f data/subdomains-1000.txt'
end

file 'data/directory-list-2.3-small.txt' do
  sh 'wget -O data/directory-list-2.3-small.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-small.txt'
end

file 'data/directory-list-2.3-small.txt.gz' => 'data/directory-list-2.3-small.txt' do
  sh 'gzip -f data/directory-list-2.3-small.txt'
end
