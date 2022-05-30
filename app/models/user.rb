# frozen_string_literal: true

class User < ApplicationRecord
  include Gravtastic

  has_many :identities
  has_many :messages, through: :canteens
  has_many :canteens
  has_many :favorites
  has_many :parsers
  has_many :feedbacks
  has_many :data_proposals
  has_many :canteens, through: :parsers

  validates :login, presence: true, uniqueness: true, exclusion: %w[anonymous system]
  validates :name, presence: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true}
  validates :notify_email, presence: true, if: :developer?
  validates :public_name, presence: true, if: :info_url?

  default_scope -> { where.not(login: %w[anonymous system]) }

  gravtastic secure: true, default: :mm, filetype: :gif, size: 100

  def admin?
    admin
  end

  def logged?
    true
  end

  def internal?
    false
  end

  def destructible?
    !admin?
  end

  def destroy
    return false unless destructible?

    super
  end

  def gravatars?
    true
  end

  def info_url?
    info_url.present?
  end

  def language
    self[:language] || Rails.configuration.i18n.default_locale.to_s
  end

  def time_zone
    self[:time_zone] || Rails.configuration.time_zone.to_s
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def can?(*attr)
    ability.can?(*attr)
  end

  def cannot?(*attr)
    ability.cannot?(*attr)
  end

  def has_favorite?(canteen)
    favorites.where(canteen_id: canteen).any?
  end

  class << self
    def create_omniauth(info, identity)
      info ||= {}
      create(
        name: (info["name"] || identity.uid),
        login: (info["login"] || identity.uid),
        email: info["email"]
      ).tap do |user|
        identity.update! user: user
      end
    end

    def anonymous
      anonymous = AnonymousUser.unscoped.find_by(login: "anonymous")
      return anonymous if anonymous

      ::ActiveRecord::Base.transaction do
        # Acquire table lock to ensure they cannot be two anonymous created concurrently
        ::ActiveRecord::Base.connection.execute("LOCK users IN EXCLUSIVE MODE;")

        # Look for anonymous user again as it could have been created concurrently
        # between the check above and getting the table lock
        record = AnonymousUser.unscoped.find_or_initialize_by(login: "anonymous")
        record.save! validate: false if record.new_record?
        record
      end
    end
  end
end
