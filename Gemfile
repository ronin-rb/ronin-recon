# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

platform :jruby do
  gem 'jruby-openssl', '~> 0.7'
end

# Ronin dependencies
# gem 'ronin-support',  '~> 1.0', github: "ronin-rb/ronin-support",
#                                 branch: '1.0.0'
# gem 'ronin-core',     '~> 0.1', github: "ronin-rb/ronin-core",
#                                 branch: 'main'
# gem 'ronin-repos',    '~> 0.1', github: "ronin-rb/ronin-repos",
#                                 branch: 'main'

group :development do
  gem 'rake'
  gem 'rubygems-tasks',   '~> 0.2'

  gem 'rspec',            '~> 3.0'
  gem 'simplecov',        '~> 0.20'

  gem 'kramdown',         '~> 2.0'
  gem 'kramdown-man',     '~> 0.1'

  gem 'redcarpet',        platform: :mri
  gem 'yard',             '~> 0.9'
  gem 'yard-spellcheck',  require: false

  gem 'dead_end',         require: false
  gem 'sord',             require: false, platform: :mri
  gem 'stackprof',        require: false, platform: :mri
  gem 'rubocop',          require: false, platform: :mri
  gem 'rubocop-ronin',    require: false, platform: :mri
end
