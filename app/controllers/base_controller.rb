class BaseController < ActionController::Base
  before_action :base_setup

  # **** setup ****

  def base_setup
    User.current = User.anonymous
  end

  # **** accessors ****

  def current_user
    User.current
  end
  helper_method :current_user

  def current_user=(user)
    User.current = user
  end

  def current_ability
    @current_ability ||= setup_ability
  end

  def setup_ability
    current_user.ability
  end

  # **** errors ****

  def error(error)
    error = {message: error} unless error.is_a?(Hash)

    error[:status] ||= :internal_server_error
    error[:message] = t(:message, scope: error[:message]) if error[:message].is_a?(Symbol)
    error[:message] = t(:message, scope: "errors.#{error[:status]}") if error[:message].nil?

    error[:title] = t(:title, scope: error[:title]) if error[:title].is_a?(Symbol)
    error[:title] = t(:title, scope: "errors.#{error[:status]}") if error[:title].nil?

    render_error error
  end

  def render_error(error)
    head error[:status]
  end
end
