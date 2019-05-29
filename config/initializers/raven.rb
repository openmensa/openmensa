# frozen_string_literal: true

# Configure Sentry-Raven if raven_dsn secret is set

if Rails.application.secrets.raven_dsn
  Raven.configure do |config|
    config.dsn = Rails.application.secrets.raven_dsn
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
