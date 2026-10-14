# frozen_string_literal: true

require "spec_helper"

describe FetchFeedJob do
  let(:_0800) { Time.utc(2015, 4, 20, 8, 0, 0) }
  let(:_0900) { Time.utc(2015, 4, 20, 9, 0, 0) }
  let(:updater) { instance_double(OpenMensa::Updater, update: true) }
  let(:feed) { create(:feed, schedule: "0 8-9 * * *") }

  before do
    Timecop.freeze(Time.utc(2015, 4, 20, 8, 34, 30))
    allow(OpenMensa::Updater).to receive(:new).and_return(updater)
  end

  it "fetches a due feed and schedules the next fetch" do
    feed
    perform_enqueued_jobs

    expect(OpenMensa::Updater).to have_received(:new).with(feed, "schedule")
    expect(feed.reload.next_fetch_at).to eq _0900
    expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0900).once
  end

  it "keeps fetching on schedule" do
    feed
    perform_enqueued_jobs
    perform_scheduled_jobs(times: 1)

    expect(OpenMensa::Updater).to have_received(:new).twice
    expect(feed.reload.next_fetch_at).to eq Time.utc(2015, 4, 21, 8, 0, 0)
    expect(FetchFeedJob).to have_been_enqueued.once
  end

  it "reports errors and retries a failed fetch" do
    feed.update!(retry: [10, 2])
    allow(updater).to receive(:update).and_raise(StandardError, "boom")
    allow(Rails.error).to receive(:report).and_call_original
    perform_enqueued_jobs

    expect(Rails.error).to have_received(:report)
      .with(an_instance_of(StandardError), hash_including(handled: true, context: {feed_id: feed.id, tags: {feed: feed.id}}))
    expect(feed.reload.next_fetch_at).to eq 10.minutes.from_now
    expect(feed.current_retry).to eq [10, 1]

    perform_scheduled_jobs(times: 1)

    expect(OpenMensa::Updater).to have_received(:new).with(feed, "retry")
  end

  it "skips stale jobs without enqueuing another one" do
    feed.update_column(:next_fetch_at, _0900)
    GoodJob::Job.delete_all
    FetchFeedJob.perform_now(feed)

    expect(OpenMensa::Updater).not_to have_received(:new)
    expect(FetchFeedJob).not_to have_been_enqueued
  end

  it "fetches only once with duplicate jobs" do
    feed
    FetchFeedJob.perform_later(feed)
    perform_enqueued_jobs

    expect(OpenMensa::Updater).to have_received(:new).once
    expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0900).once
  end

  it "is labelled per feed and canteen for concurrency control" do
    expect(FetchFeedJob.new(feed).good_job_labels).to contain_exactly("feed-#{feed.id}", "canteen-#{feed.canteen.id}")
  end

  it "is only labelled per feed without canteen" do
    feed.source.update!(canteen: nil)

    expect(FetchFeedJob.new(feed).good_job_labels).to contain_exactly("feed-#{feed.id}")
  end

  it "stops fetching inactive feeds" do
    feed.canteen.update!(state: "archived")
    perform_enqueued_jobs

    expect(OpenMensa::Updater).not_to have_received(:new)
    expect(feed.reload.next_fetch_at).to be_nil
    expect(FetchFeedJob).not_to have_been_enqueued
  end
end
