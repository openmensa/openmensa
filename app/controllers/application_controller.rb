class ApplicationController < BaseController
  protect_from_forgery

  before_filter :setup_user

  rescue_from ::CanCan::AccessDenied,         with: :error_access_denied
  rescue_from ::ActiveRecord::RecordNotFound, with: :error_not_found

  # **** setup ****

  def setup_user
    user = find_current_user
    if user and user.logged?
      self.current_user = user
      Time.zone         = current_user.time_zone
      I18n.locale       = current_user.language
    end
  end

  def find_current_user
    User.find_by_id(session[:user_id])
  end

  # **** accessors & helpers ****

  def current_user=(user)
    session[:user_id] = user ? user.id : nil
    super
  end

  def current_ability
    curent_user.ability
  end

  def flash_for(node, flashs = {})
    flash[node] ||= {}
    flash[node].merge! flashs
  end

  # **** authentication ****

  def require_authentication!
    unless current_user.logged?
      # redirect_to login_url(ref: request.fullpath)
      error_access_denied
      return false
    end
    true
  end

  def return_me
    User.find(params[:user_id])
  end

  def require_me_or_admin
    @user = return_me
    unless current_user == @user or current_user.admin?
      error_access_denied
    end
  end

  # **** error handling and rendering ****

  def error_not_found; error status: :not_found end
  def error_access_denied; error status: :unauthorized end

  def render_error(error)
    layout = error[:layout] || 'application'
    file   = error[:file] || 'common/error'

    @title   = error[:title]
    @message = error[:message]

    if (params[:format] || 'html') == 'html'
      render template: file, layout: layout, status: error[:status]
    else
      super
    end
  end
end
