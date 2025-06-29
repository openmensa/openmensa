# frozen_string_literal: true

headless = ENV["CI"] || %w[0 false off].exclude?(ENV.fetch("HEADLESS", "on").downcase)
warn "INFO: Running system specs in headless browser." if headless

Capybara.default_driver = :custom_cuprite

Capybara.register_driver(:custom_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    headless:,
    inspector: true,
    process_timeout: 120,
    timeout: 120,
    window_size: [1280, 800],
    url_whitelist: %r{^https?://(127.0.0.1|localhost)},
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:custom_cuprite)
  end
end
