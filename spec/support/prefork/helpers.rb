
def set_current_user(user)
  controller.current_user = user.is_a?(User) ? user : nil
end

def mock_file(file)
  File.new Rails.root.join('spec', 'mocks', file)
end

def login_with(identity)
  login(identity)
end

def login_as(user)
  login(user.identities.first)
end

def login(identity)
  old_mock = OmniAuth.config.mock_auth[identity.provider.to_sym]

  OmniAuth.config.add_mock(identity.provider.to_sym, {
    uid: identity.uid,
    credentials: {
      token: identity.token,
      secret: identity.secret
    }
  })

  visit logout_path
  visit "/auth/#{identity.provider}"

  OmniAuth.config.mock_auth[identity.provider.to_sym] = old_mock
end

def phantom_image(name)
  page.driver.render("tmp/#{name}.png", :full => true)
end

def auth_basic(client)
  unless client.is_a?(Hash)
    client = { id: client.identifier, secret: client.secret }
  end
  { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(client[:id], client[:secret]) }
end

def auth_bearer(token)
  token = token.token if token.respond_to?(:token)
  { "HTTP_AUTHORIZATION" => "Bearer #{token.to_s}" }
end

def auth_via_oauth2(token)
  request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN] = token
end
