class CanteensController < ApplicationController

  def index

  end

  def show
    @canteen = Canteen.find params[:id]
  end
end
