class StaticController < ApplicationController
  respond_to :html

  def index
    page = params[:id].gsub /[^A-z0-9_\-]/, ''

    render file: 'static/' + page
  end
end
