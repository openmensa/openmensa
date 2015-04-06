class CanteenErrorsController < ApplicationController
  before_action :load_resource
  before_action :new_resource

  def new
  end

  def create
    if @canteen.update_attributes active: true
      flash[:notice] = t('message.error_reported')
      redirect_to canteen_path @canteen
    else
      flash[:error] = t('message.error_report_failed')
      render action: :new
    end
  end

  private

  def new_resource
    @error_report = if @user.nil? or @user.internal?
      User.anonymous
    else
      @user
    end.error_reports.new
  end

  def load_resource
    @canteen = Canteen.find params[:canteen_id]
    authorize! :show, @canteen
  end
end
