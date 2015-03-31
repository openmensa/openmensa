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
    params.require(:user).permit(:name, :email, :send_reports)
  end
end
