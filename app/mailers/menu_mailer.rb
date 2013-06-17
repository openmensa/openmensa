class MenuMailer < ActionMailer::Base
  default from: "mail@openmensa.org"

  def today_menu(user, canteens, date)
    @user = user
    @canteens = canteens
    @date = date
    mail to: user.email, subject: t('mailer.today_menu.subject')
  end
end
