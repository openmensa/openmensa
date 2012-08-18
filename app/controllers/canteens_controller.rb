class CanteensController < ApplicationController
  before_filter :require_authentication!, except: [ :show ]
  before_filter :require_me_or_admin, except: [ :show ]

  def require_me_or_admin
    @user = User.find(params[:user_id])
    unless current_user == @user or current_user.admin?
      error_access_denied
    end
  end

  def index
  end

  def new
    @canteen = Canteen.new
  end

  def create
    @canteen = Canteen.new params[:canteen].merge(user: @user)
    if @canteen.save
      flash[:notice] = t "message.canteen_added"
      redirect_to edit_user_canteen_path(@user, @canteen)
    else
      render action: :new
    end
  end

  def edit
    @canteen = @user.canteens.find(params[:id])
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
end
