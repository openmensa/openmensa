require 'bcrypt'

class Identity < ApplicationRecord
  SERVICES = [:twitter, :google, :facebook, :github]

  belongs_to :user

  validates_presence_of :provider, :uid
  validates_uniqueness_of :uid, scope: :provider

  def self.from_omniauth(auth)
    find_omniauth(auth) || new_with_omniauth(auth)
  end

  def self.find_omniauth(auth)
    find_by_provider_and_uid(auth['provider'], auth['uid'].to_s)
  end

  def self.new_with_omniauth(auth, user = nil)
    new do |identity|
      identity.user     = user
      identity.provider = auth['provider']
      identity.uid      = auth['uid'].to_s
      if auth['credentials']
        identity.token    = auth['credentials']['token']
        identity.secret   = auth['credentials']['secret']
      end
    end
  end

  def self.providers
    Rails.configuration.omniauth_services
  end
end
