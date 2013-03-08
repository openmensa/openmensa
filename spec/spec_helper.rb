require 'rubygems'

# Setup coverage
unless ENV['DRB']
  require 'simplecov'
  require 'simplecov-rcov'
  require 'support/coverage'
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'accept_values_for'
require 'capybara/rspec'
require 'factory_girl'
require 'webmock/rspec'
require 'capybara/poltergeist'

# Load factories
FactoryGirl.reload

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false

  config.before :each do
    Timecop.return
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
  Capybara.javascript_driver = :poltergeist
  WebMock.disable_net_connect!(:allow_localhost => true)
end
