# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.0.3'
gem 'rails-i18n', '~> 6.0'
gem 'sprockets', '~> 4.0'
gem 'turbolinks', '~> 5'

gem 'puma', '~> 4.3', '>= 4.3.5'

gem 'bcrypt'
gem 'nokogiri'
gem 'oj'
gem 'pg', '~> 1.2'
gem 'slim'

gem 'cancancan', '~> 3.1'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'

gem 'parse-cron'
gem 'rack-cors', require: 'rack/cors'
gem 'whenever', require: false

gem 'geocoder', '~> 1.6'
gem 'gravtastic'
gem 'leaflet-rails', '~> 1.6', '>= 1.6.0'
gem 'rails-timeago'

gem 'api-responder'
gem 'decorate-responder', '~> 2.1'
gem 'draper', '~> 4.0'
gem 'has_scope', '~> 0.7.1'
gem 'paginate-responder', '~> 2.0'
gem 'responders'
gem 'will_paginate'

gem 'sentry-raven'

group :assets do
  gem 'autoprefixer-rails', '~> 9.8'
  gem 'bourbon', '~> 7.0'
  gem 'coffee-rails', '~> 5.0.0'
  gem 'font-awesome-sass-rails', '~> 3.0.2.2'
  gem 'jquery-rails'
  gem 'mini_racer'
  gem 'sass-rails', '~> 6.0'
  gem 'uglifier', '~> 4.2'
end

group :development do
  gem 'brakeman'

  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'rubocop', '~> 0.89.1', require: false
  gem 'rubocop-performance', '~> 1.7', require: false
  gem 'rubocop-rails', '~> 2.7', require: false
  gem 'rubocop-rspec', '~> 1.43', require: false
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails', '4.0.1'
end

group :test do
  gem 'accept_values_for', '>= 0.7.4'
  gem 'capybara', '~> 3.33'
  gem 'capybara-email', '~> 3.0'
  gem 'cuprite', '~> 0.11'
  gem 'factory_bot_rails', '~> 6.1'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'webmock'

  gem 'codecov', require: false
  gem 'simplecov', require: false
end
