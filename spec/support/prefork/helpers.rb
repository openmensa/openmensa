
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
  OmniAuth.config.add_mock(identity.provider, {
    uid: identity.uid,
    credentials: {
      token: identity.token,
      secret: identity.secret
    }
  })

  visit logout_path
  visit "/auth/#{identity.provider}"
end

def basic(client)
  { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(client.identifier, client.secret) }
end

def oauth2(token)
  token = token.token if token.respond_to?(:token)
  { "HTTP_AUTHORIZATION" => "Bearer #{token.to_s}" }
end

def auth_via_oauth2(token)
  request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN] = token
end
