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

    @meals = @canteen.meals.for(@date)
    @title = @canteen.name

    response.link canteen_url(@canteen), rel: :canonical
    response.link canteen_url(@canteen, date: (@date + 1.day)), rel: :next
    response.link canteen_url(@canteen, date: (@date - 1.day)), rel: :prev
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
