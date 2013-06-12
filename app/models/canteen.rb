require 'open-uri'
require 'rexml/document'

class Canteen < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  has_many :days
  has_many :meals, through: :days
  has_many :messages

  validates :address, :name, :user_id, presence: true

  geocoded_by :address
  after_validation :geocode, if: :geocode?

  def geocode?
    return false unless Rails.env.production? or Rails.env.development?
    !(address.blank? || (!latitude.blank? && !longitude.blank?)) || address_changed?
  end

  def fetch_hour_default
    read_attribute(:fetch_hour_default) || 8
  end

  def fetch(options={})
    OpenMensa::Updater.new(self, options).update
  end
end
