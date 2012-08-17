class UsersController < ApplicationController
  def index
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash_for :user, notice: t('message.profile_saved').html_safe
      redirect_to user_path(@user)
    else
      render action: :show
    end
  end
end
