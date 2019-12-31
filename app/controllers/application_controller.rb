# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # **** accessors ****

  def current_user
    @current_user ||= User.anonymous
  end

  attr_writer :current_user
  helper_method :current_user

  def current_ability
    current_user.ability
  end

  # **** errors ****

  def error(error)
    error = {message: error} unless error.is_a?(Hash)

    error[:status] ||= :internal_server_error

    if error[:message].is_a?(Symbol)
      error[:message] = t(:message, scope: error[:message])
    end

    if error[:message].nil?
      error[:message] = t(:message, scope: "errors.#{error[:status]}")
    end

    if error[:title].is_a?(Symbol)
      error[:title] = t(:title, scope: error[:title])
    end

    if error[:title].nil?
      error[:title] = t(:title, scope: "errors.#{error[:status]}")
    end

    render_error error
  end

  def render_error(error)
    head error[:status]
  end
end
