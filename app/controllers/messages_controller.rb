class MessagesController < ApplicationController
  before_filter :require_authentication!, except: [ :show ]
  before_filter :require_me_or_admin, except: [ :show ]

  def require_me_or_admin
    @user = User.find(params[:user_id])
    unless current_user == @user or current_user.admin?
      error_access_denied
    end
  end

  def index
    @messages = @user.messages.order(["canteens.name", :updated_at]).includes(:canteen)
  end
end
