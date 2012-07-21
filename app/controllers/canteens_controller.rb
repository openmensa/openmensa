class CanteensController < ApplicationController

  def index

  end

  def show
    @canteen = Canteen.find params[:id]
    @date    = Time.zone.now.to_date
    @meals   = @canteen.meals.where(date: @date)
  end
end
