# frozen_string_literal: true

require "spec_helper"

describe ScheduleFeedsJob do
  let(:_0800) { Time.utc(2015, 4, 20, 8, 0, 0) }
  let(:_0900) { Time.utc(2015, 4, 20, 9, 0, 0) }
  let(:feed) { create(:feed, schedule: "0 8-9 * * *") }

  before do
    Timecop.freeze(Time.utc(2015, 4, 20, 8, 34, 30))
    feed
  end

  it "keeps existing fetch jobs" do
    ScheduleFeedsJob.perform_now

    expect(FetchFeedJob).to have_been_enqueued.with(feed).once
  end

  it "schedules missing fetch jobs" do
    feed.update_column(:next_fetch_at, _0900)
    GoodJob::Job.delete_all

    ScheduleFeedsJob.perform_now

    expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0900).once
  end

  it "schedules a fetch job if only stale jobs exist" do
    feed.update_column(:next_fetch_at, _0900)

    ScheduleFeedsJob.perform_now

    expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0900).once
  end

  it "keeps jobs rescheduled to a later time" do
    GoodJob::Job.update_all(scheduled_at: _0900) # e.g. by concurrency control

    ScheduleFeedsJob.perform_now

    expect(FetchFeedJob).to have_been_enqueued.with(feed).once
  end

  it "restarts feeds without next fetch time" do
    feed.update_column(:next_fetch_at, nil)
    GoodJob::Job.delete_all

    ScheduleFeedsJob.perform_now

    expect(feed.reload.next_fetch_at).to eq _0800
    expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0800).once
  end

  it "clears next fetch time of inactive feeds" do
    feed.update_column(:schedule, nil)

    ScheduleFeedsJob.perform_now

    expect(feed.reload.next_fetch_at).to be_nil
  end
end
