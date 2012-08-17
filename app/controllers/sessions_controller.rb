class SessionsController < ApplicationController

  def new
    respond_to do |format|
      format.html { redirect_to root_url and return if User.current.logged? }
    end
  end

  def create
    return failure unless request.env["omniauth.auth"]

    @identity = Identity.from_omniauth(request.env["omniauth.auth"])
    if @identity
      if User.current.logged?
        return redirect_back alert: t('message.account_taken.' + @identity.provider, name: @identity.user.name)

      else
        self.current_user = @identity.user
        return redirect_back notice: t('message.login_successful', name: @identity.user.name)
      end

    else
      @identity = Identity.new_with_omniauth(request.env["omniauth.auth"])

      if User.current.logged?
        @identity.user = User.current
        @identity.save!
        return redirect_back notice: t('message.identity_added.' + @identity.provider, name: @identity.user.name).html_safe

      else
        @user = User.new
        if request.env["omniauth.auth"]["info"]
          @user.login      = request.env["omniauth.auth"]["info"]["login"] || @identity.uid
          @user.name       = request.env["omniauth.auth"]["info"]["name"] || @identity.uid
          @user.email      = request.env["omniauth.auth"]["info"]["email"]
        else
          @user.login      = @identity.uid
          @user.name       = @identity.uid
        end
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
    if params[:ref] and params[:ref][0] == '/'
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
