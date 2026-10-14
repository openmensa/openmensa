# frozen_string_literal: true

class ScheduleFeedsJob < ApplicationJob
  queue_as :default

  good_job_concurrency_rule(
    label: name,
    apply_label: true,
    total_limit: 1,
  )

  def perform
    Feed.inactive.where.not(next_fetch_at: nil).update_all(next_fetch_at: nil) # rubocop:disable Rails/SkipsModelValidations

    # Latest scheduled time per label. Jobs scheduled before the feed's
    # next fetch time will skip themselves when run. Later times can come
    # from GoodJob rescheduling jobs, e.g. due to concurrency limits.
    scheduled = Hash.new(0)
    jobs = GoodJob::Job.unfinished.where(job_class: FetchFeedJob.name)
    jobs.pluck(:labels, :scheduled_at).each do |labels, scheduled_at|
      labels.each {|label| scheduled[label] = [scheduled[label], scheduled_at.to_i].max }
    end

    Feed.active.find_each do |feed|
      if feed.next_fetch_at.nil?
        logger.info "Restarting schedule of feed #{feed.id}"
        feed.reset_schedule!
      elsif scheduled[FetchFeedJob.label(feed)] < feed.next_fetch_at.to_i
        logger.info "Scheduling missing fetch of feed #{feed.id}"
        feed.schedule_fetch
      end
    end
  end
end
