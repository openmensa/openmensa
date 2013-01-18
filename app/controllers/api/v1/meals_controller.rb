class Api::V1::MealsController < Api::V1::BaseController

  def index
    @canteen = Canteen.find params[:cafeteria_id]
    respond_with @canteen.meals
  end

  def show
    @canteen = Canteen.find params[:cafeteria_id]
    respond_with @canteen.meals.find(params[:id])
  end
end
