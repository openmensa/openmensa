# frozen_string_literal: true

class VerifyMailer < ApplicationMailer
  def verify_email(user, url)
    @user = user
    @url = url
    mail to: @user.notify_email, subject: t("mailer.verify_email.subject")
  end
end
