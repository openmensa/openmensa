# frozen_string_literal: true

class FeedFetch < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :feed
  has_many :messages, as: :messageable

  STATES = %w[fetching failed broken invalid empty unchanged changed].freeze
  REASONS = %w[schedule retry manual].freeze

  validates :executed_at, :reason, presence: true
  validates :state, inclusion: {in: STATES, message: "%{value} is not a valid feed state"}
  validates :reason, inclusion: {in: REASONS, message: "%{value} is not a valid feed state"}

  def init_counters
    self.added_meals = 0
    self.updated_meals = 0
    self.removed_meals = 0
    self.added_days = 0
    self.updated_days = 0
  end
end
