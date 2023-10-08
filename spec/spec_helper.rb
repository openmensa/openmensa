# frozen_string_literal: true

require "rubygems"
require "simplecov"
require "simplecov-cobertura"

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter
]

if (name = ENV.fetch("COVERAGE_NAME", nil))
  SimpleCov.command_name name
end

SimpleCov.start "rails" do
  enable_coverage :branch
  add_filter "spec"
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

ActiveRecord::Migration.maintain_test_schema!

require "capybara/cuprite"
require "capybara/email/rspec"
require "capybara/rspec"
require "factory_bot"
require "rspec/rails"
require "webmock/rspec"

# Load factories
FactoryBot.reload

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false

  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    # mocks.verify_partial_doubles = true
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Include FactoryBot methods, such as `#create`, `#build`, and
  # `#attributes_for` into spec namespace. This is the recommended way
  # on how to use these methods, and checked by a linter.
  config.include FactoryBot::Syntax::Methods

  config.before do
    Timecop.return
  end

  OmniAuth.config.test_mode = true
  OmniAuth.config.add_mock(:twitter, uid: "12345", nickname: "zapnap")
  OmniAuth.config.add_mock(:github, uid: "98765", nickname: "zapnap")

  headless = ENV["CI"] || %w[0 false off].exclude?(ENV.fetch("HEADLESS", "on").downcase)
  warn "INFO: Running feature specs in headless browser." if headless

  Capybara.default_driver = :cuprite

  Capybara.register_driver(:cuprite) do |app|
    Capybara::Cuprite::Driver.new(
      app,
      headless:,
      inspector: true,
      process_timeout: 120,
      timeout: 120,
      window_size: [1280, 800],
      url_whitelist: ["http://127.0.0.1"]
    )
  end

  WebMock.disable_net_connect!(allow_localhost: true)
end
