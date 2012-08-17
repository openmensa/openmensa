class UsersController < ApplicationController
  before_filter :require_authentication!
  before_filter :require_me_or_admin

  def require_me_or_admin
    @user = User.find(params[:id])
    unless current_user == @user or current_user.admin?
      error_access_denied
    end
  end

  def show
  end

  def update
    if @user.update_attributes(params[:user])
      flash_for :user, notice: t('message.profile_saved').html_safe
      redirect_to user_path(@user)
    else
      render action: :show
    end
  end
end
