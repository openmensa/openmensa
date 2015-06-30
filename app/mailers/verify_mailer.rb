class VerifyMailer < ActionMailer::Base
  default from: 'mail@openmensa.org'

  def verify_email(user, url)
    @user = user
    @url = url
    mail to: @user.notify_email, subject: t('mailer.verify_email.subject')
  end
end
