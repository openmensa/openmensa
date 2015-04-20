class SourcesController < ApplicationController
  before_action :load_resource, only: [:update, :edit, :sync]
  load_and_authorize_resource

  def new
    @canteen_id = params[:canteen_id]
    @parser = Parser.find params[:parser_id]
    if @canteen_id.present?
      @canteen = Canteen.find @canteen_id
      @source = Source.new canteen: @canteen, parser: @parser
    else
      @canteens = Canteen.where state: 'wanted'
      @canteen = Canteen.new
      render action: 'select_canteen'
    end
  end

  def create
    if @source.update source_params
      flash[:notice] = t 'message.source_created'
      redirect_to parser_path(@source.parser)
    else
      @canteen = @source.canteen
      flash[:error] = t 'message.source_invalid'
      render action :new
    end
  end

  def edit
    @new_feed = @source.feeds.new
  end

  def update
    if @source.update source_params
      flash[:notice] = t 'message.source_saved'
      redirect_to parser_path(@source.parser)
    else
      flash[:notice] = t 'message.source_invalid'
      redirect_to parser_path(@source.parser)
    end
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
