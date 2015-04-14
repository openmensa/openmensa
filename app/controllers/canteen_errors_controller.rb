class CanteenErrorsController < ApplicationController
  before_action :load_resource
  before_action :new_resource

  def new
  end

  def create
    if @error_report.update_attributes error_params
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

  def error_params
    params.require(:error_report).permit(:message)
  end
end
