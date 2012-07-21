class CanteensController < ApplicationController

  def index

  end

  def show
    if params[:date]
      @date  = Date.parse params[:date]
    else
      @date  = Time.zone.now.to_date
    end

    @canteen = Canteen.find params[:id]
    @meals   = @canteen.meals.where(date: @date)
  end
end
