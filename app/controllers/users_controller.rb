# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def update
    if @user.update user_params
      flash_for :user, notice: t('message.profile_saved').html_safe
      redirect_to @user
    else
      render action: :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :public_name, :info_url,
                                 :email, :notify_email, :public_email)
  end
end
