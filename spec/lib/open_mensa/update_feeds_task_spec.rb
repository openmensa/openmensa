# frozen_string_literal: true

require "spec_helper"

describe OpenMensa::UpdateFeedsTask do
  let(:task) { described_class.new }
  let(:_9am) { Time.zone.local 2015, 4, 20, 9, 0, 0 }
  let(:_8am) { Time.zone.local 2015, 4, 20, 8, 0, 0 }
  let(:next_8am) { Time.zone.local 2015, 4, 21, 8, 0, 0 }
  let(:_815) { Time.zone.local 2015, 4, 20, 8, 15, 0 }
  let(:_835) { Time.zone.local 2015, 4, 20, 8, 35, 0 }
  let(:_834) { Time.zone.local 2015, 4, 20, 8, 34, 0 }
  let(:feed) { create(:feed) }
  let(:success_updater) { double("Updater", update: true) }
  let(:failing_updater) { double("Updater", update: false) }

  before { Timecop.freeze 2015, 4, 20, 8, 34, 30 }

  def new_feed(attrs = {})
    create(:feed, attrs)
  end

  describe "#do" do
    it "clears next_fetch_at for feeds without schedule" do
      feed = new_feed next_fetch_at: 2.seconds.from_now, schedule: nil
      expect { task.do }.to change { feed.reload.next_fetch_at }.to(nil)
    end

    it "calculates missing next_fetch_at values with past value" do
      feed = new_feed schedule: "0 8-9 * * *", retry: nil
      expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(success_updater)
      expect { task.do }.to change { feed.reload.next_fetch_at }.to(_9am)
    end

    it "reports and fallback on new feeds with invalid schedule" do
      feed = new_feed schedule: "0 8-9 asdf * *", retry: nil
      expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(success_updater)
      expect { task.do }.to change { feed.reload.next_fetch_at }.to(next_8am)
    end

    context "with successful fetch" do
      it "fetches and calculate next_fetch_at on success" do
        feed = new_feed schedule: "0 8-9 * * *", retry: nil, next_fetch_at: _8am
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(success_updater)
        expect { task.do }.to change { feed.reload.next_fetch_at }.to(_9am)
      end
    end

    context "with failed update" do
      it "uses next cron time without retry" do
        feed = new_feed schedule: "0 8-9 * * *", retry: nil, next_fetch_at: _8am
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.next_fetch_at }.to(_9am)
      end

      it "uses first retry interval on error" do
        feed = new_feed schedule: "0 8-9 * * *", retry: [10],
          next_fetch_at: _8am, current_retry: [10]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.next_fetch_at }.to(10.minutes.from_now)
      end

      it "decrements retry count on error" do
        feed = new_feed schedule: "0 8-9 * * *", retry: [10, 2],
          next_fetch_at: _8am, current_retry: [10, 2]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.current_retry } \
          .to([10, 1])
      end

      it "shoulds remove zero retry counts" do
        feed = new_feed schedule: "0 8-9 * * *", retry: [10, 1, 15],
          next_fetch_at: _8am, current_retry: [10, 1, 15]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.current_retry } \
          .to([15])
      end

      it "shoulds remove zero retry counts" do
        feed = new_feed schedule: "0 8-9 * * *", retry: [10, 1, 15],
          next_fetch_at: _8am, current_retry: [10, 1, 15]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.current_retry } \
          .to([15]).and change { feed.reload.next_fetch_at }.to(10.minutes.from_now)
      end

      it "shoulds clear current_retry on last retry" do
        feed = new_feed schedule: "0 8-9 * * *", retry: [10, 1],
          next_fetch_at: _8am, current_retry: [10, 1]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.current_retry } \
          .to(nil).and change { feed.reload.next_fetch_at }.to(10.minutes.from_now)
      end

      it "shoulds clear current_retry on last retry" do
        feed = new_feed schedule: "0 8-9 * * *", retry: [10, 1],
          next_fetch_at: _8am, current_retry: [10, 1]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.current_retry } \
          .to(nil).and change { feed.reload.next_fetch_at }.to(10.minutes.from_now)
      end

      it "uses normal cron time if retry would be later" do
        feed = new_feed schedule: "*/5 8-9 * * *", retry: [360, 1],
          next_fetch_at: _8am, current_retry: [360, 1]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.next_fetch_at }.to(_835)
        expect(feed.current_retry).to eq feed.retry
      end

      it "uses normal cron time if retry would be later" do
        feed = new_feed schedule: "*/5 8-9 * * *", retry: [120, 3],
          next_fetch_at: _834, current_retry: [120, 1]
        expect(OpenMensa::Updater).to receive(:new).with(feed, "retry").and_return(failing_updater)
        expect { task.do }.to change { feed.reload.current_retry } \
          .to([120, 3]).and change { feed.reload.next_fetch_at }.to(_835)
        expect(feed.current_retry).to eq feed.retry
      end
    end

    it "fetches feeds in next_fetch_at order" do
      feed = new_feed schedule: "*/15 8-9 * * *", next_fetch_at: _815
      feed2 = new_feed schedule: "0 8-9 * * *", next_fetch_at: _8am
      expect(OpenMensa::Updater).to receive(:new).with(feed2, "schedule").ordered.and_return(success_updater)
      expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").ordered.and_return(success_updater)

      task.do
    end

    it "onlies fetch active feeds/sources" do
      feed = new_feed schedule: "*/15 8-9 * * *", next_fetch_at: _815
      feed3 = new_feed schedule: "0 8-9 * * *", next_fetch_at: _834
      feed3.canteen.update state: "archived"

      expect(OpenMensa::Updater).to receive(:new).with(feed, "schedule").ordered.and_return(success_updater)
      expect(OpenMensa::Updater).not_to receive(:new)

      task.do
    end
  end
end
