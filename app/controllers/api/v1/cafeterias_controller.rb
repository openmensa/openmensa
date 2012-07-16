class Api::V1::CafeteriasController < Api::V1::BaseController

  def index
    @canteens = Canteen.all
  end

  def show
    @canteen = Canteen.find params[:id]
  end
end
