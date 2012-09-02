require 'open-uri'
require 'rexml/document'

class Canteen < ActiveRecord::Base
  belongs_to :user
  has_many :days
  has_many :meals, through: :days
  has_many :messages

  attr_accessible :address, :name, :url, :user, :latitude, :longitude
  validates :address, :name, :user_id, presence: true

  geocoded_by :address
  after_validation :geocode, if: :geocode?

  def geocode?
    return false if Rails.env.test?
    !(address.blank? || (!latitude.blank? && !longitude.blank?)) || address_changed?
  end

  def fetch_hour
    read_attribute(:fetch_hour) || 8
  end

  def fetch
    OpenMensa::Updater.new(self).update
  end
end
