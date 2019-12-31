# frozen_string_literal: true

class MenuController < WebController
  def show
    require_authentication!
    authorize! :show, @user
    @date = if params[:date]
              Date.parse params[:date].to_s
            else
              Time.zone.now.to_date
            end

    @canteens = @user.favorites.includes(:canteen).map(&:canteen)
  end
end
