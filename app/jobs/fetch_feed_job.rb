# frozen_string_literal: true

class FetchFeedJob < ApplicationJob
  queue_as :feeds

  good_job_concurrency_rule(
    label: -> { self.class.label(arguments.first) },
    apply_label: true,
    perform_limit: 1,
  )

  # Only run one update per canteen to avoid concurrent updates e.g.
  # from full and today feed.
  good_job_concurrency_rule(
    label: -> { self.class.canteen_label(arguments.first) },
    apply_label: true,
    perform_limit: 1,
  )

  def self.label(feed)
    "feed-#{feed.id}"
  end

  def self.canteen_label(feed)
    "canteen-#{feed.source.canteen_id}" if feed.source.canteen_id
  end

  def perform(feed)
    # Reload, to get possible changes between the fetch before the
    # concurrency check and now.
    feed.reload

    return feed.reset_schedule! unless feed.active?
    return unless feed.fetch_due?

    reason = feed.current_retry == feed.retry ? "schedule" : "retry"
    success = begin
      OpenMensa::Updater.new(feed, reason).update
    rescue StandardError => e
      logger.warn "Error while fetching feed #{feed.id}: #{e.message}"
      Rails.error.report(e, handled: true, context: {feed_id: feed.id, tags: {feed: feed.id}})
      false
    end

    feed.schedule_next_fetch(success:)
    feed.save!
  end
end
