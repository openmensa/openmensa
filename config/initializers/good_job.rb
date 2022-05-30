# frozen_string_literal: true

Rails.application.configure do
  config.active_job.queue_adapter = :good_job

  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.on_thread_error = ->(err) { Raven.capture_exception(err) }

  config.good_job.execution_mode = :async
  config.good_job.max_threads = 5
  config.good_job.shutdown_timeout = 25 # seconds

  config.good_job.enable_cron = true
  config.good_job.cron = {
    update_feeds: {
      cron: "*/5 * * * *",
      class: "UpdateFeedsJob"
    },
    update_parsers: {
      cron: "0 1 * * *",
      class: "UpdateParsersJob"
    },
    update_sources: {
      cron: "0 4 * * *",
      class: "UpdateSourcesJob"
    },
    dails_reports: {
      cron: "0 9 * * *",
      class: "DailyReportsJob"
    }
  }
end
