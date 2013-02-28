class StaticController < ApplicationController
  respond_to :html

  def index
    page = (params[:id] || 'index').gsub /[^A-z0-9_\-]/, ''
    @favorites = if current_user.internal?
      []
    else
      current_user.favorites.order('priority')
    end

    render file: 'static/' + page
  end
end
