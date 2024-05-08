# frozen_string_literal: true

class MenuController < WebController
  skip_authorization_check only: :show

  def show
    unless current_user.logged?
      redirect_to root_url
      return
    end

    @date = if params[:date]
              Date.parse params[:date].to_s
            else
              Time.zone.now.to_date
            end

    @canteens = @user.favorites.includes(:canteen).map(&:canteen)
  end
end
