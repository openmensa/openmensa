class FeedFetch < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :feed
  has_many :messages, as: :messageable

  STATES = %w(fetching failed broken empty unchanged changed)
  REASONS = %w(schedule retry manual)

  validates :executed_at, :reason, presence: true
  validates :state, inclusion: { in: STATES, message: '%{value} is not a valid feed state' }
  validates :reason, inclusion: { in: REASONS, message: '%{value} is not a valid feed state' }
end
