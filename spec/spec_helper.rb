require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# Setup coverage
def init_coverage
  require 'simplecov'
  require 'simplecov-rcov'
  require 'support/coverage'
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'rails'
end


Spork.prefork do
  init_coverage unless ENV['DRB']

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'accept_values_for'
  require 'attribute_ext/rspec'
  require 'capybara/rspec'
  require 'factory_girl'
  require 'webmock/rspec'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/prefork/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = false
    config.infer_base_class_for_anonymous_controllers = false

    config.before :all do
      DatabaseCleaner.strategy = :truncation
      # DatabaseCleaner.clean

      # disable when using selenium
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before :each do
      Timecop.return
      DatabaseCleaner.start
    end

    config.after :each  do
      DatabaseCleaner.clean
    end

    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:twitter, {
      :uid => '12345',
      :nickname => 'zapnap'
    })
    OmniAuth.config.add_mock(:github, {
      :uid => '98765',
      :nickname => 'zapnap'
    })

    Capybara.default_host = 'http://example.org'
  end
end

Spork.each_run do
  init_coverage if ENV['DRB']

  FactoryGirl.reload
  Dir[Rails.root.join("spec/support/runtime/**/*.rb")].each {|f| require f}

  initialize_in_memory_database if in_memory_database?
end
