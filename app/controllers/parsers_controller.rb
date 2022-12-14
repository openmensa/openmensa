# frozen_string_literal: true

class ParsersController < WebController
  before_action :new_resource, only: %i[new create]
  before_action :load_resource, only: %i[show edit update sync]
  load_and_authorize_resource

  def show
    @sources = @parser.sources.includes(:feeds)
  end
  def new; end

  def edit; end
  def create
    if @parser.update parser_params
      flash[:notice] = t "message.parser_created"
      redirect_to parser_path(@parser)
    else
      render action: :new
    end
  end



  def update
    if @parser.update parser_params
      flash[:notice] = t "message.parser_saved"
      redirect_to parser_path @parser
    else
      show
      render action: :show
    end
  end

  def sync
    @synchroniser = OpenMensa::ParserUpdater.new @parser
    @synchroniser.sync
  end

  private

  def load_resource
    @parser = Parser.find params[:id]
  end

  def new_resource
    @parser = @user.parsers.new
  end

  def parser_params
    params.require(:parser).permit(:name, :info_url, :index_url, :maintainer_wanted)
  end
end
