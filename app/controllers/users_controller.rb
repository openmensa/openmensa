class UsersController < ApplicationController
  before_filter :require_authentication!
  before_filter :require_me_or_admin

  def show
  end

  def update
    if @user.update_attributes user_params
      flash_for :user, notice: t('message.profile_saved').html_safe
      redirect_to user_path(@user)
    else
      render action: :show
    end
  end

private
  def return_me
    User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :send_reports)
  end
end
