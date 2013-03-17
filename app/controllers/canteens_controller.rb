class CanteensController < ApplicationController
  before_filter :new_resource, only: [ :new, :create ]
  before_filter :load_resource, only: [ :show, :update, :edit ]
  load_and_authorize_resource

  def index
    @canteens = @user.canteens.order(:name)
  end

  def new
  end

  def create
    if @canteen.update canteen_params
      flash[:notice] = t 'message.canteen_added'
      redirect_to edit_user_canteen_path(@user, @canteen)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @canteen.update canteen_params
      flash[:notice] = t 'message.canteen_saved'
      redirect_to user_canteens_path(@user)
    else
      render action: :edit
    end
  end

  def show
    if params[:date]
      @date  = Date.parse params[:date]
    else
      @date  = Time.zone.now.to_date
    end

    @meals = @canteen.meals.where(date: @date)
  end

private
  def load_resource
    @canteen = Canteen.find params[:id]
  end

  def new_resource
    @canteen = @user.canteens.new
  end

  def canteen_params
    params.require(:canteen).permit(:address, :name, :url, :fetch_hour, :latitude, :longitude)
  end
end
