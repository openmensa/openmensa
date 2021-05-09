# frozen_string_literal: true

SENTRY_DSN = ENV.fetch("SENTRY_DSN", Rails.application.secrets.sentry_dsn)

if SENTRY_DSN.present?
  Sentry.init do |config|
    config.dsn = SENTRY_DSN
    config.breadcrumbs_logger = %i[active_support_logger http_logger]

    # Do not send full list of gems with each event
    config.send_modules = false

    # Set tracesSampleRate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production
    config.traces_sample_rate = 1.0

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = lambda do |event, _hint|
      # use Rails' parameter filter to sanitize the event
      filter.filter(event.to_hash)
    end
  end
end
