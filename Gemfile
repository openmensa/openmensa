source 'https://rubygems.org'

gem 'rails', '~> 4.1.7'
gem 'jquery-rails'
gem 'turbolinks'

gem 'slim'
gem 'oj', platforms: :ruby
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'rails-i18n'
gem 'cancan'
gem 'gravtastic'
gem 'rails-timeago'
gem 'bcrypt'

gem 'whenever', require: false

gem 'rack-cors', require: 'rack/cors'
gem 'rack-piwik', require: 'rack/piwik', github: 'jgraichen/rack-piwik'
gem 'rakwik', '~> 0.4', '>= 0.4.3', require: false
gem 'geocoder', github: 'mswart/geocoder', branch: 'order_by_without_select'
gem 'leaflet-rails', '~> 0.7.0'
gem 'nokogiri'
gem 'draper'
gem 'responders'
gem 'has_scope'
gem 'will_paginate'
gem 'paginate-responder'
gem 'decorate-responder'
gem 'api-responder'

gem 'pg', platforms: :ruby
gem 'activerecord-jdbcpostgresql-adapter', platforms: :jruby
gem 'jruby-openssl', platforms: :jruby
gem 'newrelic_rpm'

group :assets do
  gem 'sass', '~> 3.2.19' # 3.4 results in
    # "#content section header ul.actions a" failed to @extend "%action-link".
  gem 'sass-rails',   '~> 4.0.0', '>= 4.0.2'
  gem 'coffee-rails', '~> 4.0.0'

  gem 'therubyracer', '~> 0.10', platforms: :ruby
  gem 'therubyrhino', platforms: :jruby
  gem 'font-awesome-sass-rails', '>= 3.0.2.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'bourbon', '~> 3.2'
end

group :production do
  gem 'puma'
end

group :development do
  gem 'brakeman'

  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'spring'
end

group :development, :test do
  gem 'rspec-rails'#, '~> 2.0'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'cany', '~> 0.5.0'
end

group :test do
  gem 'timecop'
  gem 'accept_values_for'
  gem 'webmock'
  gem 'capybara',       require: false
  gem 'poltergeist',    require: false
  gem 'turn',           require: false
  gem 'coveralls',      require: false
  gem 'simplecov',      require: false
  gem 'simplecov-rcov', require: false
  gem 'factory_girl_rails', '>= 3.3.0', require: false
end

gem 'rubysl', platform: :rbx

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + '/Gemfile.local'
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
