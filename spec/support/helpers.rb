# frozen_string_literal: true

def visit_with(path, params = nil)
  if params.nil?
    params = path
    path   = url
  end
  visit path.to_s + (params.respond_to?(:to_param) ? params.to_param : "")
end

def set_current_user(user)
  controller.current_user = user.is_a?(User) ? user : nil
end

def mock_file(file)
  File.new Rails.root.join("spec", "mocks", file)
end

def mock_content(file)
  File.new(Rails.root.join("spec", "mocks", file)).read
end

def login_as(user)
  login(user.identities.first)
end

def login(identity)
  old_mock = OmniAuth.config.mock_auth[identity.provider.to_sym]

  OmniAuth.config.add_mock(
    identity.provider.to_sym,
    uid: identity.uid,
    credentials: {
      token: identity.token,
      secret: identity.secret,
    },
  )

  visit logout_path
  visit login_path
  click_on class: "btn-#{identity.provider}"

  OmniAuth.config.mock_auth[identity.provider.to_sym] = old_mock
end

def image(name)
  page.save_screenshot "tmp/#{name}.png"
end

def auth_basic(client)
  client = {id: client.identifier, secret: client.secret} unless client.is_a?(Hash)
  {"HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(client[:id], client[:secret])}
end

def auth_bearer(token)
  token = token.token if token.respond_to?(:token)
  {"HTTP_AUTHORIZATION" => "Bearer #{token}"}
end

def auth_via_oauth2(token)
  request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN] = token
end

def xml_node(name)
  Nokogiri::XML::Node.new(name, document)
end

def xml_meal(meal_name)
  meal = xml_node("meal")
  meal << name = xml_node("name")
  name << meal_name
  meal
end

def xml_text(name, text)
  node = xml_node(name)
  node << text
  node
end
