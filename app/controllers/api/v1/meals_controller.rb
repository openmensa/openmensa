class Api::V1::MealsController < Api::V1::BaseController

  def index
    @canteen = Canteen.find params[:cafeteria_id]
    @meals   = @canteen.meals
  end

  def show
    @canteen = Canteen.find params[:cafeteria_id]
    @meal    = @canteen.meals.find params[:id]
  end
end
