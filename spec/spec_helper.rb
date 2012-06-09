
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'accept_values_for'
require 'discover'
require 'attribute_ext/rspec'
require 'database_cleaner'
# require "cancan/matchers"

require 'capybara/rspec'
Capybara.javascript_driver = :webkit_debug

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

initialize_in_memory_database if in_memory_database?

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false # will be done by database_cleaner

  config.before :each do
    Timecop.return
  end

  config.before(:all) do
    DatabaseCleaner.strategy = :truncation
    # DatabaseCleaner.clean

    # disable when using selenium
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Enable OmniAuth test mode when testing for external authentication in test case/suite.
  # Do NOT enable it globally because internal authentication will break.
  # OmniAuth.config.test_mode = true
  # OmniAuth.config.add_mock(:internal, { provider:    "internal",
  #                                       uid:         "1234",
  #                                       credentials: { secret: "password" }})

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end
