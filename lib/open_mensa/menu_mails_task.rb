class OpenMensa::MenuMailsTask
  def do
    Rails.logger.info "[#{Time.zone.now}] Sending menu mails users ..."
    MailNotification.all.each do |notify|
      MenuMailer.today_menu(notify.user, notify.user.favorites.map(&:canteen), Date.today)
    end
    Rails.logger.info "[#{Time.zone.now}] Sended menu mails users"
  end
end
