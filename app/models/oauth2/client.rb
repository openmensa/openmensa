class Oauth2::Client < ActiveRecord::Base
  self.table_name = 'oauth2_clients'

  has_many :access_tokens, class_name: 'Oauth2::AccessToken'
  has_many :refresh_tokens, class_name: 'Oauth2::RefreshToken'
  belongs_to :user

  before_validation :setup, on: :create

  validates :name, :website, :redirect_uri, :secret,
    presence: true
  validates :identifier,
    presence: true, uniqueness: true

  safe_attributes :name, :website, :user, :redirect_uri, :user, :identifier, :secret

  def ability
    @ability ||= Ability::Client.new self
  end

  private
    def setup
      self.identifier = SecureRandom.hex 16
      self.secret     = SecureRandom.hex 32
    end
end
