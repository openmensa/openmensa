class Feed < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :source
  has_many :fetches, class_name: 'FeedFetch'
  has_many :messages, as: :messageable
  scope :fetch_needed, -> {
    where.has { next_fetch_at < Time.zone.now }.order(:next_fetch_at)
  }

  def canteen
    source.canteen
  end

  def feed_timespans
    {
      lastday: fetches.where.has { executed_at > 1.day.ago },
      lastweek: fetches.where.has { executed_at > 1.week.ago },
      total: fetches
    }
  end
end
