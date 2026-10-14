# frozen_string_literal: true

require "spec_helper"

describe Feed do
  let(:_0800) { Time.utc(2015, 4, 20, 8, 0, 0) }
  let(:_0830) { Time.utc(2015, 4, 20, 8, 30, 0) }
  let(:_0840) { Time.utc(2015, 4, 20, 8, 40, 0) }
  let(:_0900) { Time.utc(2015, 4, 20, 9, 0, 0) }

  before { Timecop.freeze(Time.utc(2015, 4, 20, 8, 34, 30)) }

  describe "schedule" do
    it "starts with the most recent scheduled time" do
      feed = create(:feed, schedule: "0 8-9 * * *")

      expect(feed.next_fetch_at).to eq _0800
      expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0800)
    end

    it "falls back to a daily schedule on invalid schedules" do
      feed = create(:feed, schedule: "0 8-9 asdf * *")

      expect(feed.next_fetch_at).to eq _0800
    end

    it "falls back to a daily schedule if a schedule cannot be evaluated" do
      feed = create(:feed, schedule: "0 8 L-3 * *")

      expect(feed.next_fetch_at).to eq _0800
    end

    it "falls back to a daily schedule on empty schedules" do
      feed = create(:feed, schedule: "")

      expect(feed).to be_active
      expect(feed.next_fetch_at).to eq _0800
    end

    it "is not scheduled without schedule" do
      feed = create(:feed, schedule: nil)

      expect(feed.next_fetch_at).to be_nil
      expect(FetchFeedJob).not_to have_been_enqueued
    end

    it "is not scheduled for archived canteens" do
      feed = build(:feed)
      feed.canteen.update!(state: "archived")
      feed.save!

      expect(feed.next_fetch_at).to be_nil
    end

    it "schedules a job for the new time when the schedule changes" do
      feed = create(:feed, schedule: "0 8-9 * * *", retry: [10, 2])
      feed.update_columns(current_retry: [10, 1]) # in the middle of retries
      feed.update!(schedule: "30 8 * * *")

      expect(feed.next_fetch_at).to eq _0830
      expect(feed.current_retry).to eq [10, 2]
      expect(FetchFeedJob).to have_been_enqueued.with(feed).at(_0830).once
    end
  end

  describe "#schedule_next_fetch" do
    let(:feed) { build(:feed, schedule: "0 8-9 * * *", retry: retries, current_retry: retries) }
    let(:retries) { nil }

    it "uses the next scheduled time on success" do
      feed.schedule_next_fetch(success: true)

      expect(feed.next_fetch_at).to eq _0900
    end

    it "uses the next scheduled time on failure without retry" do
      feed.schedule_next_fetch(success: false)

      expect(feed.next_fetch_at).to eq _0900
    end

    context "with retry" do
      let(:retries) { [10] }

      it "uses the retry interval on failure" do
        feed.schedule_next_fetch(success: false)

        expect(feed.next_fetch_at).to eq 10.minutes.from_now
        expect(feed.current_retry).to eq [10]
      end

      it "uses the next scheduled time on success" do
        feed.schedule_next_fetch(success: true)

        expect(feed.next_fetch_at).to eq _0900
      end
    end

    context "with retry limit" do
      let(:retries) { [10, 2] }

      it "decrements the retry count" do
        feed.schedule_next_fetch(success: false)

        expect(feed.next_fetch_at).to eq 10.minutes.from_now
        expect(feed.current_retry).to eq [10, 1]
      end
    end

    context "with last retry of an interval" do
      let(:retries) { [10, 1, 15] }

      it "continues with the next retry interval" do
        feed.schedule_next_fetch(success: false)

        expect(feed.next_fetch_at).to eq 10.minutes.from_now
        expect(feed.current_retry).to eq [15]
      end
    end

    context "with last retry" do
      let(:retries) { [10, 1] }

      it "clears the current retry" do
        feed.schedule_next_fetch(success: false)

        expect(feed.next_fetch_at).to eq 10.minutes.from_now
        expect(feed.current_retry).to be_nil
      end
    end

    context "with retry after the next scheduled time" do
      let(:feed) { build(:feed, schedule: "*/10 8-9 * * *", retry: [120, 3], current_retry: [120, 1]) }

      it "uses the next scheduled time and resets the retries" do
        feed.schedule_next_fetch(success: false)

        expect(feed.next_fetch_at).to eq _0840
        expect(feed.current_retry).to eq [120, 3]
      end
    end

    context "with retry interval below the minimum" do
      let(:retries) { [0, 2] }

      it "retries after the minimum fetch interval" do
        feed.schedule_next_fetch(success: false)

        expect(feed.next_fetch_at).to eq 5.minutes.from_now
      end
    end

    context "with schedule more often than the minimum" do
      let(:feed) { build(:feed, schedule: "* * * * *") }

      it "fetches after the minimum fetch interval" do
        feed.schedule_next_fetch(success: true)

        expect(feed.next_fetch_at).to eq 5.minutes.from_now
      end
    end

    context "with schedule including seconds" do
      let(:feed) { build(:feed, schedule: "* * * * * *") }

      it "fetches after the minimum fetch interval" do
        feed.schedule_next_fetch(success: true)

        expect(feed.next_fetch_at).to eq 5.minutes.from_now
      end
    end
  end
end
