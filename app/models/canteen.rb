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

  def fetch_if_needed
    return false unless ((fetch_hour || fetch_hour_default) .. 14).include? Time.zone.now.hour
    fetch today: !last_fetched_at.nil? && last_fetched_at.to_date == Time.zone.now.to_date
  end
end
