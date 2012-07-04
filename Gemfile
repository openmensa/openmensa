source 'https://rubygems.org'

gem 'rails', '3.2.6'
gem 'jquery-rails'

gem 'haml'
gem 'rabl'
gem 'msgpack', '~> 0.4.5'
gem 'oj'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-twitter'
gem 'rack-oauth2'
gem 'rails-i18n'
gem 'attribute_ext', '>= 1.4.0'
gem 'cancan'
gem 'simple_form',   '>= 2.0.0'
gem 'gravtastic'
gem 'rails-timeago', '>= 1.3.0'
gem 'bcrypt-ruby',   '~> 3.0.0'
gem 'paperclip'
gem 'versionist'

gem 'sqlite3'

group :assets do
  gem 'sass',         '>= 3.2.alpha.0'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', platforms: :ruby
  gem 'closure-compiler'
  gem 'compass-rails'
  gem 'bourbon'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rails_best_practices'
  gem 'thin'
  gem 'rspec-rails', '~> 2.0'
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano_colors'
end

group :test do
  gem 'timecop'
  gem 'accept_values_for'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'capybara',       require: false
  gem 'turn',           require: false
  gem 'guard-rails',    require: false
  gem 'guard-rspec',    require: false
  gem 'guard-spork',    require: false
  gem 'simplecov',      require: false
  gem 'simplecov-rcov', require: false
  gem 'spork-rails', '>= 3.2.0'
  gem 'factory_girl_rails', '>= 3.3.0', require: false
end

# load Gemfile.local
local_gemfile = File.dirname(__FILE__) + '/Gemfile.local'
if File.file?(local_gemfile)
  self.instance_eval Bundler.read_file(local_gemfile)
end
