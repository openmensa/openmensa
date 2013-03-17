class SessionsController < ApplicationController
  skip_authorization_check

  def new
    respond_to do |format|
      format.html { redirect_to root_url and return if current_user.logged? }
    end
  end

  def create
    return failure unless request.env['omniauth.auth']

    identity = Identity.from_omniauth(request.env['omniauth.auth'])
    if current_user.logged?
      create_identity! identity
    else
      create_session! identity
    end
  end

  def ref
    return request.env['omniauth.params']['ref'] if request.env['omniauth.params'] and request.env['omniauth.params']['ref']
    params[:ref]
  end

  def redirect_back(options = {})
    if ref and ref[0] == '/'
      redirect_to url_for(ref), options
    else
      redirect_to root_url, options
    end
  end

  def failure
    redirect_to login_url, alert: t('message.login_failed')
  end

  def destroy
    self.current_user = nil
    redirect_to root_url
  end

private
  def create_identity!(identity)
    if identity.new_record?
      identity.update_attributes! user: current_user
      redirect_back notice: t('message.identity_added.' + identity.provider, name: identity.user.name).html_safe
    else
      redirect_back alert: t('message.identity_taken.' + identity.provider, name: identity.user.name)
    end
  end

  def create_session!(identity)
    if identity.new_record?
      self.current_user = User.create_omniauth(request.env['omniauth.auth']['info'], identity)
      redirect_back notice: t('message.account_created', name: identity.user.name)
    else
      self.current_user = identity.user
      redirect_back notice: t('message.login_successful', name: identity.user.name)
    end
  end
end
