class SessionsController < ApplicationController

  def new
    respond_to do |format|
      format.html { redirect_to root_url and return if User.current.logged? }
    end
  end

  def create
    return failure unless env["omniauth.auth"]

    @identity = Identity.from_omniauth(env["omniauth.auth"])
    unless @identity
      @identity = Identity.new_with_omniauth(env["omniauth.auth"])
      @identity.save
    end
    @user     = @identity.user

    if @user
      session["identity"] = nil
      session["info"]     = nil

      self.current_user   = @user
      if params[:ref]
        redirect_to url_for(params[:ref]), notice: t('message.login_successful', name: @user.name)
      else
        redirect_to root_url, notice: t('message.login_successful', name: @user.name)
      end
    else
      session["identity"] = @identity.id
      session["info"]     = env["omniauth.auth"]["info"]

      redirect_to register_url
    end
  end

  def failure
    redirect_to login_url, alert: t('message.login_failed')
  end

  def register
    return redirect_to login_path unless session["identity"]

    identity = Identity.find(session["identity"])
    info     = session["info"] || {}

    @user = User.new
    @user.login      = identity.uid
    if params["user"]
      @user.email      = params["user"]["email"]
      @user.last_name  = params["user"]["last_name"]
      @user.first_name = params["user"]["first_name"]
    else
      @user.last_name  = info["first_name"]
      @user.first_name = info["last_name"]
    end

    if params["user"] and @user.save
      identity.user = @user
      identity.save!

      session["identity"] = nil
      session["info"]     = nil

      self.current_user = @user
      redirect_to root_url, notice: t('message.login_successful', name: identity.user.name)
    else
      render 'register'
    end
  rescue ::ActiveRecord::RecordNotFound
    redirect_to root_url
  end

  def destroy
    self.current_user = nil
    redirect_to root_url
  end
end
