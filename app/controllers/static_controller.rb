class StaticController < ApplicationController
  skip_authorization_check
  respond_to :html

  def index
  end

  def impressum
  end

  def about
  end

  def support
  end

  def contribute
  end
end
