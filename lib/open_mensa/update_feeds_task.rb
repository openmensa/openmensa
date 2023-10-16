# frozen_string_literal: true

class OpenMensa::UpdateFeedsTask
  attr_reader :next_cron_time

  def do
    Rails.logger.info "[#{Time.zone.now}] Fixing next_fetch_at values ..."
    changes = fix_next_fetch_ats
    Rails.logger.info "[#{Time.zone.now}] #{changes} feeds corrected"

    Rails.logger.info "[#{Time.zone.now}] Fetch feed data..."
    fetch_needed_feeds
  end

  private

  def fix_next_fetch_ats
    changes = Feed.inactive
      .where.not(next_fetch_at: nil)
      .update_all(next_fetch_at: nil) # rubocop:disable Rails/SkipsModelValidations

    Feed.active.where(next_fetch_at: nil).find_each do |feed|
      feed.next_fetch_at = process_schedule(feed, :last)
      feed.save!
      changes += 1
    end

    changes
  end

  def fetch_needed_feeds
    Feed.fetch_needed.pluck(:id).each do |feed_id|
      feed = Feed.find feed_id

      reason = if feed.retry == feed.current_retry
                 "schedule"
               else
                 "retry"
               end
      begin
        @feed_updated = OpenMensa::Updater.new(feed, reason).update
      rescue StandardError => e
        Rails.logger.warn "Error while fetching feed data of #{feed.id} (#{e.message})"
      end

      update_next_fetch_at(feed)
      feed.save!

      GC.start
    end
  end

  def fetch_at_next_cron(feed)
    feed.next_fetch_at = next_cron_time
    feed.current_retry = feed.retry
  end

  def update_next_fetch_at(feed)
    @next_cron_time = process_schedule(feed, :next)
    # no retry possible
    return fetch_at_next_cron(feed) if @feed_updated || feed.current_retry.nil? || feed.current_retry.empty?

    next_retry_time = feed.current_retry[0].minutes.from_now
    # retry after next fetch?
    return fetch_at_next_cron(feed) if next_retry_time > next_cron_time

    feed.next_fetch_at = next_retry_time
    return if feed.current_retry.size < 2 # no retry limit?

    # update current retry
    feed.current_retry_will_change! # fix ActiveRecords array handling
    feed.current_retry[1] -= 1
    return unless feed.current_retry[1] <= 0

    feed.current_retry.shift # current interval
    feed.current_retry.shift # current limit
    feed.current_retry = nil if feed.current_retry.empty?
  end

  def process_schedule(feed, state)
    CronParser.new(feed.schedule).send state
  rescue ArgumentError
    CronParser.new("0 8 * * *").send state
  end
end
