class DataProposalsController < ApplicationController
  before_action :load_resource
  before_action :new_resource, only: [:new, :create]
  load_and_authorize_resource

  def new
  end

  def create
    if @data_proposal.update data_proposal_params
      flash[:notice] = t 'message.data_proposal_created'
      redirect_to canteen_path(@data_proposal.canteen)
    else
      render action: :new
    end
  end

  private

  def new_resource
    @data_proposal = if @user.nil? or @user.internal?
      User.anonymous
    else
      @user
    end.data_proposals.new canteen: @canteen
  end

  def load_resource
    @canteen = Canteen.find params[:canteen_id]
  end

  def data_proposal_params
    params.require(:data_proposal).permit(:name, :city, :address, :latitude, :longitude, :phone, :email)
  end
end
