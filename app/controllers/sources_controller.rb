class SourcesController < ApplicationController
  before_action :load_resource, only: [:update, :edit]
  load_and_authorize_resource

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

  private

  def load_resource
    @source = Source.find params[:id]
  end

  def source_params
    params.require(:source).permit(:name, :meta_url, :parser_id)
  end
end
