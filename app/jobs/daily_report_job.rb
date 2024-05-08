# frozen_string_literal: true

class DailyReportJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(
    total_limit: 1,
    key: -> { "daily-report-#{arguments.last[:parser_id]}" }
  )

  def perform(parser_id:)
    parser = Parser.find(parser_id)
    parser.with_lock do
      mail = ParserMailer.daily_report(parser, parser.last_report_at).deliver_now
      next if mail.nil?

      parser.update last_report_at: Time.zone.now
    end
  end
end
