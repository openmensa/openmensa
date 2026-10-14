# frozen_string_literal: true

class CleanupFeedFetchesJob < ApplicationJob
  queue_as :default

  good_job_concurrency_rule(
    label: name,
    apply_label: true,
    total_limit: 1,
  )

  def perform
    FeedFetch.where(executed_at: ..1.year.ago).delete_all
  end
end
