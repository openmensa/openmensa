class Api::V1::CafeteriasController < Api::V1::BaseController

  def index
    respond_with Canteen.scoped
  end

  def show
    respond_with Canteen.find params[:id]
  end
end
