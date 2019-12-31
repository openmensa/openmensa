# frozen_string_literal: true

class StaticController < ApplicationController
  skip_authorization_check
  respond_to :html

  def index
    if request.referer.blank? && @user && @user.logged?
      case @user.favorites.count
        when 1
          redirect_to canteen_path(@user.favorites.first.canteen)
        when (2..Float::INFINITY)
          redirect_to menu_path
      end
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
