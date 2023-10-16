# frozen_string_literal: true

class OpenMensa::DailyReportTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Sending daily reports to users ..."
    Parser.find_each do |parser|
      unless ParserMailer.daily_report(parser, parser.last_report_at).deliver_now.nil?
        parser.update last_report_at: Time.zone.now
      end
    end
    Rails.logger.info "[#{Time.zone.now}] Sended daily reports to users"
  end
end
