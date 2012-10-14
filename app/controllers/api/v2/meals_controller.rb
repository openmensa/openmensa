class Api::V2::MealsController < Api::BaseController
  respond_to :json

  def default_scope(scope)
    @canteen = Canteen.find params[:canteen_id]
    @day = @canteen.days.find params[:day_id]
    scope.where(day_id: @day.id)
  end
end
