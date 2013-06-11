source 'https://rubygems.org'

gem 'rails', '~> 4.0.0.rc1'
gem 'jquery-rails'

gem 'slim', '~> 1.3'
gem 'oj', platforms: :ruby
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'rails-i18n'
gem 'cancan'
gem 'gravtastic'
gem 'rails-timeago', '>= 1.3.0'
gem 'bcrypt-ruby',   '~> 3.0.0'

# whenever dependency with Ruby 2.0 compatibility
gem 'chronic', '~> 0.9.1'
gem 'whenever', require: false

gem 'rack-piwik', require: 'rack/piwik'
gem 'rakwik'
gem 'geocoder'
gem 'leaflet-rails', '~> 0.4.2.beta1'
gem 'nokogiri'
gem 'draper', '~> 1.0'
gem 'inherited_resources'
gem 'has_scope'
gem 'will_paginate'
gem 'paginate-responder', '~> 1.3'
gem 'decorate-responder'
gem 'api-responder'

gem 'pg', platforms: :ruby
gem 'activerecord-jdbcpostgresql-adapter', platforms: :jruby
gem 'jruby-openssl', platforms: :jruby

group :assets do
  gem 'sass', '~> 3.2.0'
  gem 'sass-rails',   '~> 4.0.0.beta1'
  gem 'coffee-script-source', '~> 1.6.1' # for source map support
  gem 'coffee-rails', '~> 4.0.0.beta1'

  gem 'therubyracer', '~> 0.10', platforms: :ruby
  gem 'therubyrhino', platforms: :jruby
  gem 'font-awesome-sass-rails', '>= 3.0.2.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'bourbon'
end

group :production do
  gem 'unicorn', platforms: :ruby
end

group :development do
  gem 'thin', platforms: :ruby
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano_colors'
  gem 'capistrano-unicorn'
  gem 'brakeman'

  gem 'guard-rspec', require: false
  gem 'listen'

  # For debugging on MRI 2.0
  gem 'ruby-debug-ide', '>= 0.4.17.beta14', require: false, platforms: :ruby
  gem 'debase', '>= 0.0.2', require: false, platforms: :ruby
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
end

group :test do
  gem 'timecop'
  gem 'accept_values_for'
  gem 'webmock'
  gem 'capybara',       require: false
  gem 'poltergeist',    require: false
  gem 'turn',           require: false
  gem 'simplecov',      require: false
  gem 'simplecov-rcov', require: false
  gem 'factory_girl_rails', '>= 3.3.0', require: false
end

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + '/Gemfile.local'
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
