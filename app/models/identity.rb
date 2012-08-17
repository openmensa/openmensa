require "bcrypt"

class Identity < ActiveRecord::Base

  SERVICES = [ :twitter, :google, :facebook, :github ]

  belongs_to :user

  validates_presence_of   :provider, :uid
  validates_uniqueness_of :uid, scope: :provider

  safe_attributes :provider, :uid, :secret, :token, :user, :user_id,
    if: proc { |identity| identity.new_record? }

  def self.from_omniauth(auth)
    find_by_provider_and_uid(auth["provider"], auth["uid"])
  end

  def self.new_with_omniauth(auth, user = nil)
    new do |identity|
      identity.user     = user
      identity.provider = auth["provider"]
      identity.uid      = auth["uid"]
      if auth["credentials"]
        identity.token    = auth["credentials"]["token"]
        identity.secret   = auth["credentials"]["secret"]
      end
    end
  end

  def self.providers
    Rails.configuration.omniauth_services
  end
end
