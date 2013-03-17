class StaticController < ApplicationController
  skip_authorization_check
  respond_to :html

  def index
    page = (params[:id] || 'index').gsub /[^A-z0-9_\-]/, ''
    render file: 'static/' + page
  end
end
