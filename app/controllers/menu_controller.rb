# frozen_string_literal: true

class MenuController < ApplicationController
  def show
    require_authentication!
    authorize! :show, @user
    if params[:date]
      @date  = Date.parse params[:date].to_s
    else
      @date  = Time.zone.now.to_date
    end

    @canteens = @user.favorites.includes(:canteen).map(&:canteen)
  end
end
