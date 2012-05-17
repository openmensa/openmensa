source 'https://rubygems.org'

gem "rails", "3.2.3"
gem "jquery-rails"

gem "haml"
gem "rabl"
gem "oj"
gem "omniauth"
gem "rails-i18n"
gem "attribute_ext", ">= 1.4.0"
gem "cancan"
gem "simple_form", ">= 2.0.0"
gem "gravtastic"
gem "rails-timeago", ">= 1.2.0.rc1"
gem "omniauth-internal"
gem "bcrypt-ruby", "~> 3.0.0"


group :assets do
  gem "sass",         ">= 3.2.alpha.0"
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "therubyracer", platforms: :ruby
  gem "closure-compiler"
  gem "compass-rails"
  gem "font-awesome-sass-rails"
  gem "bourbon"
end
group :development, :test do
  gem 'sqlite3'
  gem "rspec-rails"
  gem "guard-rails",       require: false
end
group :test do
  gem "sqlite3"
  gem "timecop"
  gem "factory_girl_rails", ">= 3.3.0"
  gem "accept_values_for"
  gem "database_cleaner"
  gem "capybara"
  gem "capybara-webkit"
  gem "spork",       require: false
  gem "turn",        require: false
  gem "guard-rspec", require: false
  gem "guard-spork", require: false
end

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + "/Gemfile.local"
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
