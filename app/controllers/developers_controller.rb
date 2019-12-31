# frozen_string_literal: true

class DevelopersController < ApplicationController
  skip_authorization_check only: %i(activate)
  def show
    authorize! :edit, @user
    if @user.developer?
      flash_for :user, notice: t('message.activate.already_developer').html_safe
    end
  end

  def update
    authorize! :edit, @user
    if @user.update user_params
      url = activate_url self.class.message_encryptor.encrypt_and_sign(@user.notify_email)
      if VerifyMailer.verify_email(@user, url).deliver_now
        flash_for :user, notice: t('message.activate.mail_sent', mail: @user.notify_email).html_safe
      else
        flash_for :user, error: t('message.activate.mail_failed_to_send', mail: @user.notify_email).html_safe
      end
      redirect_to @user
    else
      render action: :show
    end
  end

  def activate
    redirect_to root_url
    user = User.find_by notify_email: self.class.message_encryptor.decrypt_and_verify(params[:token])
    unless user
      flash[:error] = t('message.activate.unknown_token')
      return
    end
    if user.update_attributes developer: true
      flash[:notice] = t('message.activate.got_developer')
    else
      flash[:error] = t('message.activate.could_not_activate_link')
    end
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    flash[:error] = t('message.activate.invalid_message')
  end

  private
  def user_params
    params.require(:user).permit(:public_name, :info_url,
                                 :notify_email, :public_email)
  end

  class << self
    def message_encryptor
      @message_encryptor ||= ActiveSupport::MessageEncryptor.new \
        Rails.application.secrets.secret_key_base[0..31]
    end
  end
end
