# frozen_string_literal: true

if (mailer = Rails.application.config_for("mailer"))
  config = Rails.application.config

  case mailer[:delivery_method].downcase
    when "sendmail"
      config.action_mailer.delivery_method = :sendmail
    when "smtp"
      config.action_mailer.delivery_method = :smtp
  end

  if (sendmail_settings = mailer[:sendmail_settings])
    config.action_mailer.sendmail_settings ||= {}
    config.action_mailer.sendmail_settings.update(sendmail_settings)
  end

  if (smtp_settings = mailer[:smtp_settings])
    config.action_mailer.smtp_settings ||= {}
    config.action_mailer.smtp_settings.update(smtp_settings)
  end
end
