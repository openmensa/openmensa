# frozen_string_literal: true

class Feed < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :source
  has_many :fetches, class_name: 'FeedFetch'
  has_many :messages, as: :messageable

  scope :fetch_needed, lambda {
    where('next_fetch_at < ?', Time.zone.now).order(:next_fetch_at)
  }

  scope :archived, lambda {
    joins(source: :canteen).where(sources: {canteens: {state: 'archived'}})
  }

  scope :inactive, lambda {
    where('(schedule IS NULL OR id IN (?))', Feed.archived.select(:id))
  }

  scope :active, lambda {
    where('(schedule IS NOT NULL AND id NOT IN (?))', Feed.archived.select(:id))
  }

  delegate :canteen, to: :source

  def feed_timespans
    {
      lastday: fetches.where('executed_at > ?', 1.day.ago),
      lastweek: fetches.where('executed_at > ?', 1.week.ago),
      total: fetches
    }
  end
end
