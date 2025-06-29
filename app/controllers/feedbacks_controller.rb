# frozen_string_literal: true

class FeedbacksController < WebController
  before_action :load_resource
  before_action :new_resource, except: :index

  def index
    authorize! :edit, @canteen

    @feedbacks = @canteen.feedbacks.order(created_at: :desc)
  end

  def new; end

  def create
    if @feedback.update error_params
      flash[:notice] = t("message.feedback_sumitted")
      redirect_to canteen_path @canteen
    else
      flash[:error] = t("message.feedback_failed")
      render action: :new
    end
  end

  private

  def new_resource
    @feedback = user.feedbacks.new canteen: @canteen
  end

  def user
    if @user.nil? || @user.internal?
      User.anonymous
    else
      @user
    end
  end

  def load_resource
    @canteen = Canteen.find params[:canteen_id]
    authorize! :show, @canteen
  end

  def error_params
    params.require(:feedback).permit(:message)
  end
end
