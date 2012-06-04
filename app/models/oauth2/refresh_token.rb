class Oauth2::RefreshToken < ActiveRecord::Base
  include Oauth2::Token

  has_many :access_tokens

  self.table_name = 'oauth2_refresh_tokens'
  self.default_lifetime = 1.month
end
