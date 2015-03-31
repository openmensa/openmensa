class ParsersController < ApplicationController
  before_action :new_resource, only: [:new, :create]
  before_action :load_resource, only: [:show, :update]
  load_and_authorize_resource

  def show
    @sources = @parser.sources
  end

  def update
    if @parser.update canteen_params
      flash[:notice] = t 'message.parser_saved'
      redirect_to user_parser_path(@user, @parser)
    else
      show
      render action: :show
    end
  end

  private

  def load_resource
    @parser = Parser.find params[:id]
  end

  def new_resource
    @parser = @user.canteens.new
  end

  def canteen_params
    params.require(:parser).permit(:name, :info_url)
  end
end
