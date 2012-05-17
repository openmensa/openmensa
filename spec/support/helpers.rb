
def set_current_user(user)
  if user && user.logged?
    session[:user_id] = user.id
    User.current = user
  else
    session[:user_id] = nil
    User.current = User.anonymous
  end
end

def login(identity)
  # post auth_path, username: identity.uid, password: identity.secret

  visit login_path
  within 'form#login' do
    fill_in      "Login",    with: identity.uid
    fill_in      "Password", with: identity.password
    click_button "Log in"
  end
end

def stub_omniauth(identity)
  @controller.stub!(:env).and_return({"omniauth.auth" => {
    "provider" => identity.provider,
    "uid"      => identity.uid,
    "credentials" => {
      "token"  => identity.token,
      "secret" => identity.secret
    }}})
  identity
end

class Identity
  def password=(password)
    @password   = password
    self.secret = password unless password.empty?
  end

  def authenticate(password)
    return secret == password ? self : false
  end
end
