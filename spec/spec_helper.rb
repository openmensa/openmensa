require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'


Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)

  require 'rspec/rails'
  require 'accept_values_for'
  require 'attribute_ext/rspec'
  require 'capybara/rspec'
  require 'factory_girl'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/prefork/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = false

    config.before :each do
      Timecop.return
    end

    # Enable OmniAuth test mode when testing for external authentication in test case/suite.
    # Do NOT enable it globally because internal authentication will break.
    # OmniAuth.config.test_mode = true
    # OmniAuth.config.add_mock(:internal, { provider:    "internal",
    #                                       uid:         "1234",
    #                                       credentials: { secret: "password" }})
  end
end

Spork.each_run do
  FactoryGirl.reload
  Dir[Rails.root.join("spec/support/runtime/**/*.rb")].each {|f| require f}

  initialize_in_memory_database if in_memory_database?
end
