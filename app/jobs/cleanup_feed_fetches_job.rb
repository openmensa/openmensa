# frozen_string_literal: true

class CleanupFeedFetchesJob < ApplicationJob
  queue_as :default

  good_job_control_concurrency_with(total_limit: 1)

  def perform
    FeedFetch.where(executed_at: ..1.year.ago).delete_all
  end
end
