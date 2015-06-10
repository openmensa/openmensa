class FeedbacksController < ApplicationController
  before_action :load_resource
  before_action :new_resource, except: :index

  def new
  end

  def create
    if @feedback.update_attributes error_params
      flash[:notice] = t('message.feedback_sumitted')
      redirect_to canteen_path @canteen
    else
      flash[:error] = t('message.feedback_failed')
      render action: :new
    end
  end

  def index
    authorize! :edit, @canteen
    @feedbacks = @canteen.feedbacks
  end

  private

  def new_resource
    @feedback = if @user.nil? or @user.internal?
      User.anonymous
    else
      @user
    end.feedbacks.new canteen: @canteen
  end

  def load_resource
    @canteen = Canteen.find params[:canteen_id]
    authorize! :show, @canteen
  end

  def error_params
    params.require(:feedback).permit(:message)
  end
end
