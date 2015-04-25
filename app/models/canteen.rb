require 'open-uri'
require 'rexml/document'

class Canteen < ActiveRecord::Base
  has_many :days
  has_many :meals, through: :days
  has_many :messages
  has_many :sources
  has_many :parsers, through: :sources
  has_many :feeds, through: :sources
  has_many :data_proposals
  has_many :feedbacks

  scope :active, -> { where('state IN (?)', ['active', 'empty']) }

  validates :city, :name, presence: true

  geocoded_by :address
  after_validation :geocode, if: :geocode?

  STATES = %w(wanted active empty archived)
  validates :state, inclusion: { in: STATES, message: '%{value} is not a valid canteen state' }

  def geocode?
    return false unless Rails.env.production? || Rails.env.development?
    !(address.blank? || (!latitude.blank? && !longitude.blank?)) || address_changed?
  end

  def fetch_state
    if archived?
      :out_of_order
    elsif last_fetched_at.nil?
      :no_fetch_ever
    elsif last_fetched_at > Time.zone.now - 1.day
      :fetch_up_to_date
    else
      :fetch_needed
    end
  end

  def archived?
    state == 'archived'
  end
end
