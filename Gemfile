source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.1'
gem 'rails-i18n', '~> 5.0'
gem 'turbolinks', '~> 5'

gem 'puma', '~> 3.7'

gem 'slim'
gem 'oj'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'cancancan'
gem 'gravtastic'
gem 'rails-timeago'
gem 'bcrypt'

gem 'whenever', require: false
gem 'parse-cron'

gem 'rack-cors', require: 'rack/cors'
gem 'geocoder', '~> 1.4'
gem 'leaflet-rails', '~> 1.0'
gem 'nokogiri'
gem 'draper', '~> 3.0'
gem 'responders'
gem 'has_scope', '~> 0.7.1'
gem 'will_paginate'
gem 'paginate-responder'
gem 'decorate-responder'
gem 'api-responder'
gem 'baby_squeel'

gem 'pg'

group :assets do
  gem 'sass-rails', '~> 5.0'
  gem 'coffee-rails', '~> 4.2.0'
  gem 'jquery-rails'

  gem 'therubyracer'

  gem 'font-awesome-sass-rails', '~> 3.0.2.2'
  gem 'uglifier', '~> 3.1'
  gem 'bourbon', '~> 4.3'
end

group :development do
  gem 'brakeman'

  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'cany', '~> 0.5.0'
  gem 'pry'
  gem 'pry-byebug'
end

group :test do
  gem 'timecop'
  gem 'accept_values_for', github: 'bogdan/accept_values_for', ref: 'a5c02cb'
  gem 'webmock'
  gem 'capybara'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'factory_girl_rails', '>= 3.3.0'

  gem 'coveralls',      require: false
  gem 'simplecov',      require: false
  gem 'simplecov-rcov', require: false
end

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + '/Gemfile.local'
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
