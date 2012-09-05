class MessageMailer < ActionMailer::Base
  default from: "info@openmensa.org"

  def daily_report(user, messages=nil)
    @user = user
    @messages = messages || user.messages
    mail to: user.email, subject: t('mailer.daily_report.subject')
  end
end
