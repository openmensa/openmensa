# frozen_string_literal: true

class SourcesController < WebController
  before_action :load_resource, only: %i[update edit sync]
  load_and_authorize_resource

  def new
    @source = Source.new(parser:)
    @canteen = Canteen.new
  end

  def edit
    @new_feed = @source.feeds.new
  end

  def create
    @source = Source.new(source_params)
    @canteen = Canteen.new(source_canteen_params)

    ActiveRecord::Base.transaction do
      @canteen.save!
      @source.update!(parser:, canteen: @canteen)

      flash[:notice] = t "message.source_created"
      redirect_to parser_path(@source.parser)
    end
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def update
    flash[:notice] = if @source.update source_params
                       t "message.source_saved"
                     else
                       t "message.source_invalid"
                     end

    redirect_to parser_path(@source.parser)
  end

  def sync
    @synchroniser = OpenMensa::SourceUpdater.new @source
    @synchroniser.sync
  end

  private

  def parser
    @parser ||= Parser.find(params.require(:parser_id))
  end

  def load_resource
    @source = Source.find params[:id]
  end

  def source_params
    params.require(:source).permit(:name, :meta_url, :parser_id)
  end

  def source_canteen_params
    params.require(:canteen).permit(:address, :name, :latitude, :longitude, :city, :phone, :email)
  end
end
