# frozen_string_literal: true

class DevelopersController < WebController
  skip_authorization_check only: %i[activate]

  def show
    authorize!(:edit, user)
  end
  # rubocop:enable all

  def update
    authorize!(:edit, user)

    user.transaction do
      # Validate as if the user were a developer but reset afterward.
      unless user.update(**user_params, developer: true)
        user.developer = false
        render action: :show, status: :unprocessable_content
        return
      end

      user.update!(developer: false)
    end

    url = activate_url(encrypt_and_sign(user.notify_email))
    if VerifyMailer.verify_email(user, url).deliver_now
      flash_for :user, notice: t("message.activate.mail_sent", mail: user.notify_email)
    else
      flash_for :user, error: t("message.activate.mail_failed_to_send", mail: user.notify_email)
    end

    redirect_to user
  end

  def activate
    redirect_to root_url

    user = User.find_by(notify_email: decrypt_and_verify(params[:token]))

    if user.blank?
      flash[:error] = t("message.activate.unknown_token")
      return
    end

    if user.update(developer: true)
      flash[:notice] = t("message.activate.got_developer")
    else
      flash[:error] = t("message.activate.could_not_activate_link")
    end
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    flash[:error] = t("message.activate.invalid_message")
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def user_params
    params.require(:user).permit(
      :info_url,
      :notify_email,
      :public_email,
      :public_name,
    )
  end

  def encrypt_and_sign(text)
    self.class.message_encryptor.encrypt_and_sign(text)
  end

  def decrypt_and_verify(text)
    self.class.message_encryptor.decrypt_and_verify(text)
  end

  class << self
    def message_encryptor
      @message_encryptor ||= ActiveSupport::MessageEncryptor.new \
        Rails.application.secret_key_base[0..31]
    end
  end
end
