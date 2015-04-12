class OpenMensa::DailyReportTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Sending daily reports to users ..."
    Parser.all.each do |parser|
      unless ParserMailer.daily_report(parser, parser.last_report_at).deliver.nil?
        parser.update_attributes last_report_at: Time.zone.now
      end
    end
    Rails.logger.info "[#{Time.zone.now}] Sended daily reports to users"
  end
end
