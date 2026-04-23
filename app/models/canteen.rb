# frozen_string_literal: true

class Canteen < ApplicationRecord
  has_many :days, dependent: :destroy
  has_many :meals, through: :days
  has_many :messages, dependent: :destroy
  has_many :sources, dependent: :destroy
  has_many :parsers, through: :sources
  has_many :feeds, through: :sources
  has_many :data_proposals, dependent: :destroy

  has_many :feedbacks, dependent: :destroy
  belongs_to :replaced_by,
    class_name: "Canteen",
    foreign_key: :replaced_by,
    optional: true,
    inverse_of: :replacing
  has_many :replacing,
    class_name: "Canteen",
    foreign_key: :replaced_by,
    dependent: :restrict_with_exception,
    inverse_of: :replaced_by

  scope :active, -> { where(state: %w[active empty]) }
  scope :orphaned, -> { includes(:sources).where(state: %w[new active], sources: {id: nil}) }

  validates :city, :name, presence: true

  geocoded_by :address
  after_validation :geocode, if: :geocode?

  STATES = %w[new active empty archived].freeze
  validates :state, inclusion: {in: STATES}

  def geocode?
    return false unless Rails.env.production? || Rails.env.development?

    !(address.blank? || (latitude.present? && longitude.present?)) || address_changed?
  end

  def fetch_state
    if archived?
      :out_of_order
    elsif last_fetched_at.nil?
      :no_fetch_ever
    elsif last_fetched_at > 1.day.ago
      :fetch_up_to_date
    else
      :fetch_needed
    end
  end

  def archived?
    state == "archived"
  end

  def replaced?
    !self[:replaced_by].nil?
  end

  def to_label
    status = nil
    if state == "new"
      status = "[new]"
    elsif state == "active" && sources.empty?
      status = "[orphaned]"
    end

    "(#{id}) #{name} #{status}"
  end

  def slug
    @slug ||= begin
      slug = name.parameterize
      slug = id.to_s if slug.blank?
      slug
    end
  end
end
