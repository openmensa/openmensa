# frozen_string_literal: true

require "English"
class User < ApplicationRecord
  include Gravtastic

  has_many :identities, dependent: :destroy
  has_many :messages, through: :canteens
  has_many :favorites, dependent: :destroy
  has_many :parsers, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :data_proposals, dependent: :destroy
  has_many :canteens, through: :parsers

  validates :login, presence: true, uniqueness: true, exclusion: %w[anonymous system]
  validates :name, presence: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true}
  validates :notify_email, presence: true, if: :developer?
  validates :public_name, presence: true, if: :info_url?

  default_scope -> { where.not(login: %w[anonymous system]) }

  gravtastic secure: true, default: :mm, filetype: :gif, size: 100

  before_destroy :check_destructible!

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

  def check_destructible!
    raise ActiveRecord::RecordNotDestroyed unless destructible?
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

  def can?(*)
    ability.can?(*)
  end

  def cannot?(*)
    ability.cannot?(*)
  end

  def favorite?(canteen)
    favorites.where(canteen_id: canteen).any?
  end

  def denotify!
    self.email = "#{id}@example.org" if email.present?
    self.public_email = "#{id}@example.org" if public_email.present?
    self.notify_email = "#{id}@example.org" if notify_email.present?
    save!
    reload
  end

  class << self
    def create_omniauth(info, identity)
      info ||= {}
      create(
        name: info["name"] || identity.uid,
        login: info["login"] || identity.uid,
        email: info["email"]
      ).tap do |user|
        identity.update! user:
      end
    end

    def anonymous
      retried ||= false

      AnonymousUser.unscoped.find_or_initialize_by(login: "anonymous").tap do |record|
        record.save!(validate: false) if record.new_record?
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      raise $ERROR_INFO if retried

      retried = true
      retry
    end
  end
end
