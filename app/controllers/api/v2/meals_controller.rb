# frozen_string_literal: true

class Api::V2::MealsController < Api::BaseController
  respond_to :json

  def default_scope(scope)
    @canteen = Canteen.find params[:canteen_id]
    @day = @canteen.days.find_by! date: params[:day_id]

    scope
      .where(day_id: @day.id)
      .order(:pos)
      .strict_loading
      .includes(:notes)
  end

  def canteen_meals
    @canteen = Canteen.find params[:canteen_id]

    @days = @canteen.days.strict_loading.includes(meals: :notes)
    begin
      date = Date.strptime(params[:start] || "", "%Y-%m-%d")
      @days = @days
        .where("days.date >= ?", date)
        .where("days.date < ?", date + 7.days)
    rescue ArgumentError
      @days = @days
        .where("days.date >= ?", Time.zone.today)
        .where("days.date < ?", Time.zone.today + 7.days)
    end

    respond_with DayDecorator.decorate_collection(@days), include: [:meals]
  end
end
