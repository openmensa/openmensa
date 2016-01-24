source 'https://rubygems.org'

gem 'rails', '~> 4.1.10'
gem 'jquery-rails'
gem 'turbolinks'

gem 'slim'
gem 'oj'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'rails-i18n'
gem 'cancancan'
gem 'gravtastic'
gem 'rails-timeago'
gem 'bcrypt'

gem 'whenever', require: false
gem 'parse-cron'

gem 'squeel'
gem 'rack-cors', require: 'rack/cors'
gem 'geocoder', github: 'mswart/geocoder', branch: 'order_by_without_select'
gem 'leaflet-rails', '~> 0.7.0'
gem 'nokogiri'
gem 'draper'
gem 'responders'
gem 'has_scope', '0.6.0'
gem 'will_paginate'
gem 'paginate-responder'
gem 'decorate-responder'
gem 'api-responder'

gem 'pg'
gem 'skylight'

group :assets do
  gem 'sass-rails', '~> 5.0'
  gem 'coffee-rails', '~> 4.1.0'

  gem 'therubyracer', '~> 0.10'

  gem 'font-awesome-sass-rails', '>= 3.0.2.2'
  gem 'uglifier', '>= 1.3.0'
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
  gem 'rspec-rails'
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

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + '/Gemfile.local'
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
