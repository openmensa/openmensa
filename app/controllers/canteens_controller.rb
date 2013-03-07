class CanteensController < ApplicationController
  before_filter :require_authentication!, except: [ :show ]
  before_filter :require_me_or_admin, except: [ :show ]

  def index
    @canteens = @user.canteens.order(:name)
  end

  def new
    @canteen = Canteen.new
  end

  def create
    @canteen = Canteen.new canteen_params.merge(user: @user)
    if @canteen.save
      flash[:notice] = t 'message.canteen_added'
      redirect_to edit_user_canteen_path(@user, @canteen)
    else
      render action: :new
    end
  end

  def edit
    @canteen = @user.canteens.find(params[:id])
  end

  def update
    @canteen = @user.canteens.find(params[:id])
    if @canteen.update_attributes canteen_params
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

    @canteen = Canteen.find params[:id]
    @meals   = @canteen.meals.where(date: @date)
  end

private
  def canteen_params
    params.require(:canteen).permit(:address, :name, :url, :fetch_hour, :latitude, :longitude)
  end
end
