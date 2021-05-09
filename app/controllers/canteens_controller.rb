# frozen_string_literal: true

class CanteensController < WebController
  before_action :load_resource, only: %i[show update edit fetch]
  load_and_authorize_resource

  def index
    @canteens = @user.canteens.order(:name)
  end

  def create
    @canteen = Canteen.new

    if @canteen.update(canteen_params)
      flash[:notice] = t "message.canteen_added"
      redirect_to new_parser_source_path(
        parser_id: params[:parser_id],
        canteen_id: @canteen
      )
    end
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

  def show
    @date = if params[:date]
              Date.parse params[:date].to_s
            else
              Time.zone.now.to_date
            end

    @meals = @canteen.meals.for @date
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
