class Api::V2::MealsController < Api::BaseController
  respond_to :json

  def default_scope(scope)
    @canteen = Canteen.find params[:canteen_id]
    @day = @canteen.days.find_by_date! params[:day_id]
    scope.where(day_id: @day.id).order :pos
  end

  def canteen_meals
    @canteen = Canteen.find params[:canteen_id]

    @days = @canteen.days
    begin
      date = Date.strptime(params[:start] || '', '%Y-%m-%d')
      @days = @days.where('days.date >= ?', date).where('days.date < ?', date + 7.days)
    rescue ArgumentError
      @days = @days.where('days.date >= ?', Date.today).where('days.date < ?', Date.today + 7.days)
    end

    respond_with @days, include: [ :meals ]
  end
end
