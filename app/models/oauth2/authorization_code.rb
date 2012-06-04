class Oauth2::AuthorizationCode < ActiveRecord::Base
  include Oauth2::Token

  self.table_name = 'oauth2_authorization_codes'
  safe_attributes :client, :redirect_uri

  def access_token
    @access_token ||= expired! && user.access_tokens.create!(client: client)
  end
end
