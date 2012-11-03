class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Gravtastic

  has_many :identities
  has_many :messages, through: :canteens
  has_many :canteens

  validates :login, presence: true, uniqueness: true, exclusion: ['anonymous', 'system']
  validates :name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true, allow_nil: true }

  attr_accessible :login, :name, :email, :time_zone, :language, :send_reports, :admin

  scope :all, lambda { where("#{User.table_name}.login != ? AND #{User.table_name}.login != ?", 'anonymous', 'system') }

  gravtastic :secure => true, :default => :mm, :filetype => :gif, :size => 100

  def admin?; admin end
  def logged?; true end
  def internal?; false end
  def destructible?; !admin? end
  def destroy
    return false unless destructible?
    super
  end

  def gravatars?; true end

  def language
    read_attribute(:language) || Rails.configuration.i18n.default_locale.to_s
  end

  def time_zone
    read_attribute(:time_zone) || Rails.configuration.time_zone.to_s
  end

  def send_reports?
    !last_report_at.nil?
  end
  def send_reports=(bool)
    if bool.is_a? String
      bool = bool == '1'
    end
    return if bool == send_reports?
    if bool
      write_attribute :last_report_at, Time.zone.now
    else
      write_attribute :last_report_at, nil
    end
  end
  alias_method :send_reports, :send_reports?

  def ability; @ability ||= Ability.new(self) end
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
