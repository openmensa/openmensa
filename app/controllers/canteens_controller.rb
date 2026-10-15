# frozen_string_literal: true

class CanteensController < WebController
  before_action :load_resource, only: %i[show update edit]
  load_and_authorize_resource

  def index
    @canteens = @user.canteens.order(:name)
  end

  def show
    begin
      @date = Day.parse(params[:date].presence || Time.zone.now.to_date)
    rescue Date::Error
      return error_not_found
    end

    return error_not_found unless @canteen.available_dates.cover?(@date)

    @meals = @canteen.meals.for(@date)
    @title = @canteen.name

    @prev_date = @date.prev_day if @canteen.days.exists?(date: ...@date)
    @next_date = @date.next_day if @canteen.days.exists?(date: @date.next_day..Day.upcoming_dates.end)

    response.link canteen_url(@canteen), rel: :canonical
    response.link canteen_url(@canteen, date: @next_date), rel: :next if @next_date
    response.link canteen_url(@canteen, date: @prev_date), rel: :prev if @prev_date
  end

  def edit; end

  def update
    if @canteen.update canteen_params
      flash[:notice] = t "message.canteen_saved"
      redirect_to parser_path(@canteen.parsers.first)
    else
      render action: :edit
    end
  end

  private

  def load_resource
    @canteen = Canteen.find params[:id]
    @canteen = @canteen.replaced_by if @canteen.replaced?
  end

  def canteen_params
    params
      .require(:canteen)
      .permit(:address, :name, :latitude, :longitude, :city, :phone, :email)
  end
end
