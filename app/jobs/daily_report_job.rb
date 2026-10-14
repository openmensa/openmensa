# frozen_string_literal: true

class DailyReportJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { "daily-report-#{arguments.last[:parser_id]}" },
  )

  # Retry temporary mail delivery failures for a few hours, but stop
  # long before the next daily report is enqueued. This covers short
  # outages or lookup failures.
  retry_on Net::SMTPServerBusy, Net::OpenTimeout, Net::ReadTimeout, wait: 1.hour, attempts: 6 do |job, error|
    raise error unless recipient_rejected?(error)

    job.logger.info("Skip daily report for parser #{job.arguments.last[:parser_id]}: #{error.message}")
  end

  # Ignore unavailable or deliberately wrong address, such as `.noreply`
  # or `example.org`. They do not want to get emails.
  rescue_from Net::SMTPFatalError do |error|
    raise error unless self.class.recipient_rejected?(error)

    logger.info("Skip daily report for parser #{arguments.last[:parser_id]}: #{error.message}")
  end

  def perform(parser_id:)
    parser = Parser.find(parser_id)
    parser.with_lock do
      mail = ParserMailer.daily_report(parser, parser.last_report_at).deliver_now
      next if mail.nil?

      parser.update(last_report_at: Time.zone.now)
    end
  end

  class << self
    def recipient_rejected?(error)
      error.message.include?("Recipient address rejected")
    end
  end
end
