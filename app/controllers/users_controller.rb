class UsersController < ApplicationController
  before_action :load_user, only: [:show, :update]
  load_and_authorize_resource

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

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :send_reports)
  end
end
