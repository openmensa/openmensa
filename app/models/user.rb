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

  validates :login, presence: true, uniqueness: true, exclusion: %w(anonymous system)
  validates :name, presence: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true, allow_nil: true}
  validates :notify_email, presence: true, if: :developer?
  validates :public_name, presence: true, if: :info_url?

  default_scope -> { where.not(login: %w(anonymous system)) }

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

  # -- class methods
  def self.anonymous
    AnonymousUser.instance
  end

  def self.create_omniauth(info, identity)
    info ||= {}
    create(
      name: (info['name'] || identity.uid),
      login: (info['login'] || identity.uid),
      email: info['email']
      ).tap do |user|
      identity.update_attributes! user: user
    end
  end
end

class AnonymousUser < User
  validate :single_user

  def single_user
    errors.add_to_base 'An anonymous user already exists.' if self.class.find_by_login(self.class.login_id)
  end

  def logged?
    false
  end

  def admin?
    false
  end

  def name
    I18n.t(:anonymous_user)
  end

  def last_name
    name
  end

  def email
    nil
  end

  def destroy
    false
  end

  def internal?
    true
  end

  def destructible?
    false
  end

  def self.instance
    @user_instance ||= unscoped.find_by(login: login_id)
    return @user_instance if @user_instance

    user = new
    user.login = login_id
    user.save! validate: false
    raise "Cannot create #{login_id} user." if user.new_record?
    @user_instance = user
    user
  end

  def self.clear!
    @user_instance = nil
  end

  def self.login_id
    'anonymous'
  end
end
