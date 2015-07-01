class Feed < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :source
  has_many :fetches, class_name: 'FeedFetch'
  has_many :messages, as: :messageable
  scope :fetch_needed, -> {  where { next_fetch_at < Time.zone.now }.order(:next_fetch_at) }

  def canteen
    source.canteen
  end

  def feed_timespans
    {
      lastday: fetches.where { executed_at > 1.day.ago },
      lastweek: fetches.where { executed_at > 1.week.ago },
      total: fetches
    }
  end
end
