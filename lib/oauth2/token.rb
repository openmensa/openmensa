module Oauth2
  module Token
    def self.included(base)
      base.class_eval do
        cattr_accessor :default_lifetime
        self.default_lifetime = 1.minute

        belongs_to :user
        belongs_to :client, class_name: 'Oauth2::Client'

        before_validation :setup, :on => :create

        validates_presence_of   :client, :expires_at, :token
        validates_uniqueness_of :token

        safe_attributes :user, :client, :if => :new_record?

        scope :valid, lambda { where("expires_at > ?", Time.now.utc) }
      end
    end

    def expires_in
      (expires_at - Time.now.utc).to_i
    end

    def expired!
      self.expires_at = Time.now.utc
      self.save!
    end

  private

    def setup
      self.token        = SecureRandom.hex 64
      self.expires_at ||= self.default_lifetime.from_now
    end
  end
end
