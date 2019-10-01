source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.3'
gem 'rails-i18n', '~> 5.0'
gem 'turbolinks', '~> 5'

gem 'puma', '~> 4.2'

gem 'bcrypt'
gem 'nokogiri'
gem 'oj'
gem 'pg', '~> 1.0'
gem 'slim'

gem 'cancancan', '~> 2.0'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'

gem 'parse-cron'
gem 'rack-cors', require: 'rack/cors'
gem 'whenever', require: false

gem 'geocoder', '~> 1.4'
gem 'gravtastic'
gem 'leaflet-rails', '~> 1.0'
gem 'rails-timeago'

gem 'api-responder'
gem 'decorate-responder', '~> 2.0'
gem 'draper', '~> 3.1'
gem 'has_scope', '~> 0.7.1'
gem 'paginate-responder', '~> 2.0'
gem 'responders'
gem 'will_paginate'

gem 'sentry-raven'

group :assets do
  gem 'autoprefixer-rails', '~> 9.6'
  gem 'bourbon', '~> 6.0'
  gem 'coffee-rails', '~> 5.0.0'
  gem 'font-awesome-sass-rails', '~> 3.0.2.2'
  gem 'jquery-rails'
  gem 'mini_racer'
  gem 'sass-rails', '~> 6.0'
  gem 'uglifier', '~> 4.2'
end

group :development do
  gem 'brakeman'

  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'rubocop', '~> 0.75.0', require: false
  gem 'rubocop-performance', '~> 1.4', require: false
  gem 'rubocop-rails', '~> 2.3', require: false
  gem 'rubocop-rspec', '~> 1.36', require: false
end

group :development, :test do
  gem 'cany', '~> 0.5.0'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails'
end

group :test do
  gem 'accept_values_for', '>= 0.7.4'
  gem 'capybara'
  gem 'factory_bot_rails', '~> 5.1'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'webmock'

  gem 'codecov', require: false
  gem 'simplecov', require: false
end

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + '/Gemfile.local'
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
