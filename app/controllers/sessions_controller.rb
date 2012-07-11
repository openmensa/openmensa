class SessionsController < ApplicationController

  def new
    respond_to do |format|
      format.html { redirect_to root_url and return if User.current.logged? }
    end
  end

  def create
    return failure unless env["omniauth.auth"]

    @identity = Identity.from_omniauth(env["omniauth.auth"])
    if @identity
      if User.current.logged?
        return redirect_back alert: t('message.account_taken.' + @identity.provider, name: @identity.user.name)

      else
        self.current_user = @identity.user
        return redirect_back notice: t('message.login_successful', name: @identity.user.name)
      end

    else
      @identity = Identity.new_with_omniauth(env["omniauth.auth"])

      if User.current.logged?
        @identity.user = User.current
        @identity.save!
        return redirect_back notice: t('message.account_connected.' + @identity.provider, name: @identity.user.name)

      else
        @user = User.new
        @user.login      = env["omniauth.auth"]["info"]["login"] || @identity.uid
        @user.name       = env["omniauth.auth"]["info"]["name"] || @identity.uid
        @user.email      = env["omniauth.auth"]["info"]["email"]
        @user.save!

        @identity.user = @user
        @identity.save!

        self.current_user = @user

        return redirect_back notice: t('message.account_created', name: @user.name)
      end
    end
  end

  def print_debug arr, opts = { tabs: 0, name: 'root' }
    if arr.is_a?(Enumerable)
      puts ("  " * opts[:tabs]) + opts[:name]
      arr.each do |k,v|
        print_debug v, tabs: opts[:tabs] + 1, name: k.to_s
      end
    else
      puts ("  " * opts[:tabs]) + opts[:name] + " => " + arr.inspect
    end
  end

  def redirect_back(options = {})
    if params[:ref]
      redirect_to url_for(params[:ref]), options
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
end
