# frozen_string_literal: true

SENTRY_DSN = ENV.fetch("SENTRY_DSN", Settings.sentry&.dsn)

if SENTRY_DSN.present?
  Sentry.init do |config|
    config.dsn = SENTRY_DSN
    config.breadcrumbs_logger = %i[monotonic_active_support_logger http_logger]

    # Do not send full list of gems with each event
    config.send_modules = false

    # Set sampling rates to 1.0 to capture 100% of transactions and
    # profiles for performance monitoring.
    config.traces_sample_rate = 1.0
    config.profiles_sample_rate = 1.0

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = lambda do |event, _hint|
      # Sanitize extra data
      event.extra = filter.filter(event.extra) if event.extra

      # Sanitize user data
      event.user = filter.filter(event.user) if event.user

      # Sanitize context data (if present)
      event.contexts = filter.filter(event.contexts) if event.contexts

      # Return the sanitized event object
      event
    end
  end
end
