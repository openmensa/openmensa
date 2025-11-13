# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.4.0"

gem "config", "~> 5.5"
gem "dry-validation", "~> 1.10"
gem "rails", "~> 8.1.0"
gem "rails-i18n", "~> 8.0"

gem "jsbundling-rails"
gem "propshaft"
gem "rails-assets-manifest"

gem "puma", "~> 7.0"

gem "bcrypt"
gem "good_job", "~> 4.0"
gem "nokogiri"
gem "oj"
gem "pg", "~> 1.2"
gem "slim", "~> 5.0"

gem "cancancan", "~> 3.2"
gem "omniauth", "~> 2.0"
gem "omniauth-facebook"
gem "omniauth-github"
gem "omniauth-google-oauth2"
gem "omniauth-oauth2"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "omniauth-twitter"

gem "parse-cron"
gem "rack-cors", require: "rack/cors"

gem "geocoder", "~> 1.6"
gem "gravtastic"
gem "rails-timeago"
gem "simple_form"

gem "api-responder"
gem "decorate-responder", "~> 2.1"
gem "draper", "~> 4.0"
gem "has_scope", "~> 0.9.0"
gem "paginate-responder", "~> 2.0"
gem "responders"
gem "will_paginate"

gem "appsignal"
gem "sentry-rails"
gem "sentry-ruby"
gem "stackprof"
gem "telegraf"

group :development do
  gem "brakeman"

  gem "letter_opener"
  gem "listen"
  gem "spring"
  gem "spring-commands-rspec"
  gem "squasher"

  gem "rubocop", "~> 1.81.0", require: false
  gem "rubocop-capybara", "~> 2.22.0", require: false
  gem "rubocop-factory_bot", "~> 2.28.0", require: false
  gem "rubocop-performance", "~> 1.26.0", require: false
  gem "rubocop-rails", "~> 2.33.0", require: false
  gem "rubocop-rspec", "~> 3.8.0", require: false
  gem "rubocop-rspec_rails", "~> 2.31.0", require: false

  gem "web-console"
end

group :development, :test do
  gem "pry"
  gem "pry-byebug"
  gem "rspec-collection_matchers"
  gem "rspec-its"
  gem "rspec-rails", "8.0.2"
end

group :test do
  gem "capybara", "~> 3.35"
  gem "capybara-email", "~> 3.0"
  gem "cuprite", "~> 0.13"
  gem "factory_bot_rails", "~> 6.1"
  gem "rails-controller-testing"
  gem "timecop"
  gem "webmock"

  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
end
