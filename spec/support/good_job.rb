# frozen_string_literal: true

# Test helpers for jobs enqueued with GoodJob.
#
# The test environment uses GoodJob in external mode: jobs are written
# to the GoodJob tables, but not executed. The adapter provides enqueued
# and performed jobs compatible to ActiveJob test adapter. Therefore, we
# can use the original matchers but with GoodJob.
#
module GoodJobTestHelper
  class Adapter < GoodJob::Adapter
    def enqueued_jobs
      GoodJob::Job.unfinished.order(:created_at).map {|job| job_hash(job) }
    end

    def performed_jobs
      GoodJob::Execution.finished.order(:created_at).map {|execution| job_hash(execution) }
    end

    private

    def job_hash(record)
      data = record.serialized_params
      scheduled_at = Time.zone.parse(data["scheduled_at"]) if data["scheduled_at"]

      data.merge(
        job: data.fetch("job_class").constantize,
        args: data.fetch("arguments"),
        queue: data.fetch("queue_name"),
        priority: data.fetch("priority"),
        at: scheduled_at&.to_f,
      )
    end
  end

  # Performs all jobs that are due, including jobs enqueued while
  # performing them. Jobs scheduled in the future are not performed, see
  # `perform_scheduled_jobs`.
  #
  # Unlike Active Job's helper, this does not take a block.
  def perform_enqueued_jobs
    raise ArgumentError.new("perform_enqueued_jobs does not take a block, call it after enqueuing jobs") if block_given?

    GoodJob.perform_inline
  end

  # Travels to the time the next job is scheduled at, and performs all
  # jobs due by then. Useful for retries too.
  #
  # Repeats until no jobs are left, or the given number of times.
  # `limit` sets an upper ceiling to not run forever when a job
  # scheduled itself again and again.
  def perform_scheduled_jobs(times: nil, limit: 100)
    (times || limit).times do
      scheduled_at = GoodJob::Job.unfinished.minimum(:scheduled_at)
      return if scheduled_at.nil?

      if scheduled_at > Time.current
        Timecop.frozen? ? Timecop.freeze(scheduled_at) : Timecop.travel(scheduled_at)
      end

      perform_enqueued_jobs
    end

    return if times || GoodJob::Job.unfinished.none?

    raise "Jobs still scheduled after #{limit} rounds, " \
          "maybe a job keeps rescheduling itself?"
  end

  private

  # Override rspec-rails' internal check if the test adapter is used; we
  # do want to run our GoodJob adapter.
  def check_active_job_adapter
    return if ActiveJob::Base.queue_adapter.is_a?(Adapter)

    super
  end
end

ActiveJob::Base.queue_adapter = GoodJobTestHelper::Adapter.new

RSpec.configure do |config|
  config.include GoodJobTestHelper
end
