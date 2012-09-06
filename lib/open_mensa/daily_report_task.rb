class OpenMensa::DailyReportTask

  def do
    Rails.logger.info "[#{Time.zone.now}] Sending daily reports to users ..."
    User.all.each do |user|
      next unless user.developer?
      next unless user.send_reports?
      messages = user.messages.where('messages.created_at > ?', user.last_report_at).order(["canteens.name", :updated_at]).includes(:canteen)
      if messages.size > 0
        MessageMailer.daily_report(user, messages).deliver
        user.update_attribute :last_report_at, Time.zone.now
      end
    end
    Rails.logger.info "[#{Time.zone.now}] Sended daily reports to users"
  end
end
