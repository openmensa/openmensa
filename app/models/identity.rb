# frozen_string_literal: true

require "bcrypt"

class Identity < ApplicationRecord
  SERVICES = %i[twitter google facebook github].freeze

  belongs_to :user

  validates :provider, :uid, presence: true
  validates :uid, uniqueness: {scope: :provider}

  def self.from_omniauth(auth)
    find_omniauth(auth) || new_with_omniauth(auth)
  end

  def self.find_omniauth(auth)
    find_by(provider: auth["provider"], uid: auth["uid"].to_s)
  end

  def self.new_with_omniauth(auth, user = nil)
    new do |identity|
      identity.user     = user
      identity.provider = auth["provider"]
      identity.uid      = auth["uid"].to_s
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
