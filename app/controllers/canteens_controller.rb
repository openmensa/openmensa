# frozen_string_literal: true

class CanteensController < WebController
  before_action :new_resource, only: %i[new create]
  before_action :load_resource, only: %i[show update edit fetch]
  load_and_authorize_resource

  def index
    @canteens = @user.canteens.order(:name)
  end

  def new
    @canteens = Canteen.where state: 'wanted'
  end

  def create
    if @canteen.update canteen_params
      if params[:parser_id]
        flash[:notice] = t 'message.canteen_added'
        redirect_to new_parser_source_path(parser_id: params[:parser_id], canteen_id: @canteen)
      else
        flash[:notice] = t 'message.wanted_canteen_added'
        redirect_to wanted_canteens_path
      end
    else
      @canteens = Canteen.where state: 'wanted'
      render action: :new
    end
  end

  def edit; end

  def update
    if @canteen.update canteen_params
      flash[:notice] = t 'message.canteen_saved'
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

  def wanted
    @canteens = Canteen.where state: 'wanted'
  end

  private

  def load_resource
    @canteen = Canteen.find params[:id]
    @canteen = @canteen.replaced_by if @canteen.replaced?
  end

  def new_resource
    @canteen = Canteen.new
  end

  def canteen_params
    params.require(:canteen).permit(:address, :name, :latitude, :longitude, :city, :phone, :email)
  end
end
