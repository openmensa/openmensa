class Api::V1::MealsController < Api::V1::BaseController

  def index
    @cafeteria = Cafeteria.find params[:cafeteria_id]
    @meals     = @cafeteria.meals
  end

  def show
    @cafeteria = Cafeteria.find params[:cafeteria_id]
    @meal      = @cafeteria.meals.find params[:id]
  end
end
