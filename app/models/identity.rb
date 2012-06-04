require "bcrypt"

class Identity < ActiveRecord::Base
  attr_reader :password

  belongs_to :user

  validates_presence_of   :provider, :uid
  validates_uniqueness_of :uid, scope: :provider

  safe_attributes :password, :provider, :uid, :secret, :token, :user, :user_id,
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

  def authenticate(plain)
    BCrypt::Password.new(secret) == plain ? self : false
  rescue
    false
  end

  def password=(plain)
    @password = plain
    unless plain.blank?
      self.secret = BCrypt::Password.create(plain)
    end
  end

  def self.authenticate(username, password)
    find_by_provider_and_uid("internal", username).try(:authenticate, password)
  end
end
