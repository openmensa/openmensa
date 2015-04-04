class FeedsController < ApplicationController
  before_action :new_resource, only: [:new, :create]
  before_action :load_resource, only: [:update, :destroy]
  load_and_authorize_resource

  def create
    if @feed.update feed_params
      flash[:notice] = t 'message.feed_created'
      redirect_to edit_source_path(@source)
    else
      # TODO
    end
  end

  def update
    if @feed.update feed_params
      flash[:notice] = t 'message.feed_updated'
      redirect_to edit_source_path(@feed.source_id)
    else
      # TODO
    end
  end

  def destroy
    if @feed.delete
      flash[:notice] = t 'message.feed_deleted'
      redirect_to edit_source_path(@feed.source_id)
    else
      # TODO
    end
  end

  private

  def load_resource
    @feed = Feed.find params[:id]
  end

  def new_resource
    @source = Source.find params[:source_id]
    @feed = @source.feeds.new
  end

  def feed_params
    params.require(:feed).permit(:name, :url, :schedule, :retry)
  end
end
