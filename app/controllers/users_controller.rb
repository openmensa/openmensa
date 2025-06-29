# frozen_string_literal: true

class UsersController < WebController
  load_and_authorize_resource

  def show; end

  def update
    if @user.update user_params
      flash_for :user, notice: t("message.profile_saved")
      redirect_to @user
    else
      render action: :show
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :info_url,
      :name,
      :notify_email,
      :public_email,
      :public_name,
    )
  end
end
