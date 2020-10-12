# frozen_string_literal: true

class SourcesController < WebController
  before_action :load_resource, only: %i[update edit sync]
  load_and_authorize_resource

  def new
    @canteen_id = params[:canteen_id]
    @parser = Parser.find params[:parser_id]
    if @canteen_id.present?
      @canteen = Canteen.find @canteen_id
      @source = Source.new canteen: @canteen, parser: @parser
    else
      @canteens = Canteen.where state: "wanted"
      @canteen = Canteen.new
      render action: "select_canteen"
    end
  end

  def create
    if @source.update source_params
      flash[:notice] = t "message.source_created"
      redirect_to parser_path(@source.parser)
    else
      @canteen = @source.canteen
      flash[:error] = t "message.source_invalid"
      render action :new
    end
  end

  def edit
    @new_feed = @source.feeds.new
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

  def load_resource
    @source = Source.find params[:id]
  end

  def source_params
    params.require(:source).permit(:name, :meta_url, :parser_id, :canteen_id)
  end
end
