# frozen_string_literal: true

class Feed < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  # Minimum interval between fetches, as a safeguard on aggressive cron
  # and retry expressions (e.g. zero wait time)
  MIN_FETCH_INTERVAL = 5.minutes

  # Fallback for invalid schedules
  DEFAULT_SCHEDULE = "0 8 * * *"

  belongs_to :source
  has_many :fetches, class_name: "FeedFetch", dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy

  scope :archived, lambda {
    joins(source: :canteen).where(sources: {canteens: {state: "archived"}})
  }

  scope :inactive, lambda {
    where("(schedule IS NULL OR id IN (?))", Feed.unscoped.archived.select(:id))
  }

  scope :active, lambda {
    where("(schedule IS NOT NULL AND id NOT IN (?))", Feed.unscoped.archived.select(:id))
  }

  delegate :canteen, to: :source

  before_save :reset_schedule, if: -> { new_record? || will_save_change_to_schedule? || will_save_change_to_retry? }

  after_save :schedule_fetch, if: :saved_change_to_next_fetch_at?

  def active?
    !schedule.nil? && !canteen&.archived?
  end

  def fetch_due?
    next_fetch_at.present? && next_fetch_at <= Time.current
  end

  def reset_schedule
    self.next_fetch_at = active? ? cron_time(&:previous_time) : nil
    self.current_retry = self.retry
  end

  def reset_schedule!
    reset_schedule
    save!
  end

  def schedule_fetch
    return unless next_fetch_at

    FetchFeedJob.set(wait_until: next_fetch_at).perform_later(self)
  end

  def schedule_next_fetch(success:)
    next_cron_at = [cron_time(&:next_time), MIN_FETCH_INTERVAL.from_now].max
    interval, count, *rest = current_retry unless success
    retry_at = [interval.minutes, MIN_FETCH_INTERVAL].max.from_now if interval

    if retry_at.nil? || retry_at > next_cron_at
      self.next_fetch_at = next_cron_at
      self.current_retry = self.retry
      return
    end

    self.next_fetch_at = retry_at
    return if count.nil? # no retry limit

    self.current_retry = count > 1 ? [interval, count - 1, *rest] : rest.presence
  end

  def feed_timespans
    {
      lastday: fetches.where("executed_at > ?", 1.day.ago),
      lastweek: fetches.where("executed_at > ?", 1.week.ago),
      lastyear: fetches,
    }
  end

  private

  # Schedules are evaluated in UTC, the time zone of the former parser in
  # production. Schedules that are invalid or fail to be evaluated fall
  # back to the default schedule.
  def cron_time
    yield(parse_cron(schedule) || parse_cron(DEFAULT_SCHEDULE)).to_t
  rescue StandardError
    yield(parse_cron(DEFAULT_SCHEDULE)).to_t
  end

  def parse_cron(expression)
    Fugit.parse_cron("#{expression} UTC")
  end
end
