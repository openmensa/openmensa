# frozen_string_literal: true

class MenuController < WebController
  skip_authorization_check only: :show

  def show
    unless current_user.logged?
      redirect_to root_url
      return
    end

    begin
      @date = Day.parse(params[:date].presence || Time.zone.now.to_date)
    rescue Date::Error
      return error_not_found
    end

    @canteens = current_user.favorites.includes(:canteen).map(&:canteen)
  end
end
