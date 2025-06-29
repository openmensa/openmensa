# frozen_string_literal: true

class WebController < ApplicationController
  protect_from_forgery
  check_authorization

  before_action :setup_user

  unless Rails.env.development?
    rescue_from ::CanCan::AccessDenied,         with: :error_access_denied
    rescue_from ::ActiveRecord::RecordNotFound, with: :error_not_found
  end

  # **** setup ****

  def setup_user
    user = User.find_by id: session[:user_id]
    return unless user&.logged?

    self.current_user = user
    Time.zone         = current_user.time_zone
    I18n.locale       = current_user.language

    @user = if params[:user_id]
              User.find params[:user_id]
            else
              current_user
            end
  end

  # **** accessors & helpers ****

  def current_user=(user)
    session[:user_id] = user&.id
    super
  end

  def flash_for(node, flashs = {})
    flash[node] ||= {}
    flash[node].merge! flashs
  end

  # **** error handling and rendering ****

  def error_not_found
    error status: :not_found
  end

  def error_access_denied
    error status: :unauthorized
  end

  def error_too_many_requests
    error status: :too_many_requests
  end

  def render_error(error)
    layout = error[:layout] || "application"
    file   = error[:file] || "common/error"

    @title   = error[:title]
    @message = error[:message]

    if (params[:format] || "html") == "html"
      render template: file, layout:, status: error[:status]
    else
      super
    end
  end
end
