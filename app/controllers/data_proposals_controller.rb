# frozen_string_literal: true

class DataProposalsController < WebController
  before_action :load_resource
  before_action :new_resource, only: %i[new create]
  load_and_authorize_resource

  def index
    authorize! :edit, @canteen
    @data_proposals = @canteen.data_proposals.order(created_at: :desc)
  end
  def new; end

  def create
    if @data_proposal.update data_proposal_params
      flash[:notice] = t "message.data_proposal_created"
      redirect_to canteen_path(@data_proposal.canteen)
    else
      render action: :new
    end
  end


  private

  def new_resource
    @data_proposal = user.data_proposals.new canteen: @canteen
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
  end

  def data_proposal_params
    params
      .require(:data_proposal)
      .permit(:name, :city, :address, :latitude, :longitude, :phone, :email)
  end
end
