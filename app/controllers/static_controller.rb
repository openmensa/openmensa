class StaticController < ApplicationController
  skip_authorization_check
  respond_to :html

  def index
    if request.referer.blank? && @user.logged? && @user.favorites.any?
      redirect_to menu_path
    end
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
