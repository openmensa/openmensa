class User < ActiveRecord::Base
  has_many :identities

  # Oauth2 associations
  has_many :access_tokens, class_name: 'Oauth2::AccessToken'
  has_many :authorization_codes, class_name: 'Oauth2::AuthorizationCode'
  has_many :clients, class_name: 'Oauth2::Client'

  validates_presence_of :login, :name
  validates_uniqueness_of :login
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true, allow_nil: true
  validates_exclusion_of :login, in: ['anonymous', 'system']

  safe_attributes :login, :name, :email, :time_zone, :language,
    if: Proc.new { |user,as| user.new_record? or as.admin? }
  safe_attributes :name, :email, :time_zone, :language,
    if: Proc.new { |user,as| user == as }
  safe_attributes :admin,
    if: Proc.new { |user,as| as.admin? }

  scope :all,    lambda { where("#{User.table_name}.login != ? AND #{User.table_name}.login != ?", 'anonymous', 'system') }

  include Gravtastic
  gravtastic :secure => true, :default => :identicon, :filetype => :gif, :size => 100


  def admin?; admin end
  def logged?; true end
  def internal?; false end
  def destructible?; !admin? end
  def destroy
    return false unless destructible?
    super
  end

  def gravatars?; true end
  def to_param; login end

  def language
    read_attribute(:language) || Rails.configuration.i18n.default_locale.to_s
  end

  def time_zone
    read_attribute(:time_zone) || Rails.configuration.time_zone.to_s
  end

  def ability; @ability ||= Ability::User.new(self) end
  def can?(*attr) ability.can?(*attr) end
  def cannot?(*attr) ability.cannot?(*attr) end

  # -- class methods
  def self.current
    @current_user || self.anonymous
  end

  def self.current=(user)
    @current_user = user
  end

  def self.anonymous
    AnonymousUser.instance
  end

  def self.system
    SystemUser.instance
  end
end


class SystemUser < User
  validate :single_user

  def single_user
    errors.add_to_base 'A system user already exists.' if self.class.find_by_login(self.class.login_id)
  end

  def logged?; false end
  def admin?; true end
  def name; I18n.t(:system_user) end
  def last_name; name end
  def email; nil end
  def destroy; false end
  def internal?; true end
  def destructible?; false end

  def self.instance
    user = @user_instance || find_by_login(login_id)
    return user if user

    user = self.new
    user.login = login_id
    user.save :validate => false
    raise "Cannot create #{login_id} user." if user.new_record?
    @user_instance = user
    user
  end

  def self.login_id; 'system' end
end


class AnonymousUser < SystemUser
  def admin?; false end
  def name; I18n.t(:anonymous_user) end
  def self.login_id; 'anonymous' end
end
