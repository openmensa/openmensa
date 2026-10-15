# frozen_string_literal: true

require "spec_helper"

describe Canteen do
  let(:canteen) { create(:canteen) }

  describe "#name" do
    it "is not valid without a name" do
      canteen = build(:canteen, name: nil)
      expect(canteen).not_to be_valid
    end

    it "is not valid with an empty name" do
      canteen = build(:canteen, name: "")
      expect(canteen).not_to be_valid
    end
  end

  describe "#state" do
    it "is not valid without a state" do
      canteen = build(:canteen, state: nil)
      expect(canteen).not_to be_valid
    end

    it "is not valid with an empty state" do
      canteen = build(:canteen, state: "")
      expect(canteen).not_to be_valid
    end

    it "is not valid with an illegal state value" do
      canteen = build(:canteen, state: "invalid-value")
      expect(canteen).not_to be_valid
    end

    it "accepts the 'new' value" do
      canteen = build(:canteen, state: "new")
      expect(canteen).to be_valid
    end

    it "accepts the 'active' value" do
      canteen = build(:canteen, state: "active")
      expect(canteen).to be_valid
    end

    it "accepts the 'empty' value" do
      canteen = build(:canteen, state: "empty")
      expect(canteen).to be_valid
    end

    it "accepts the 'archived' value" do
      canteen = build(:canteen, state: "archived")
      expect(canteen).to be_valid
    end
  end

  describe "#fetch_state" do
    subject { canteen.fetch_state }

    context "when canteen is disabled" do
      before do
        canteen.update_attribute :state, "archived"
      end

      it { is_expected.to eq :out_of_order }
    end

    context "when updated in the last 24 hours" do
      before do
        canteen.update_attribute :last_fetched_at, 4.hours.ago
      end

      it { is_expected.to eq :fetch_up_to_date }
    end

    context "when updated earlier than 24 hours ago" do
      before do
        canteen.update_attribute :last_fetched_at, 25.hours.ago
      end

      it { is_expected.to eq :fetch_needed }
    end

    context "when never updated" do
      before do
        canteen.update_attribute :last_fetched_at, nil
      end

      it { is_expected.to eq :no_fetch_ever }
    end
  end

  describe "#available_dates" do
    let(:today) { Time.zone.today }

    it "ranges from today to the future limit without days" do
      expect(canteen.available_dates).to eq today..(today + Day::MAX_FUTURE)
    end

    it "starts at the first day" do
      create(:day, canteen:, date: today - 10)

      expect(canteen.available_dates).to eq (today - 10)..(today + Day::MAX_FUTURE)
    end
  end

  describe "feed schedules" do
    let!(:feed) { create(:feed, source: create(:source, canteen:), schedule: "0 8-9 * * *") }

    before do
      Timecop.freeze(Time.utc(2015, 4, 20, 8, 34, 30))
      canteen.update!(state: "archived")
      feed.update_column(:next_fetch_at, nil) # as done by FetchFeedJob
      GoodJob::Job.delete_all
    end

    it "restarts feeds when the canteen is no longer archived" do
      canteen.update!(state: "active")

      expect(feed.reload.next_fetch_at).to eq Time.utc(2015, 4, 20, 8, 0, 0)
      expect(FetchFeedJob).to have_been_enqueued.with(feed)
    end
  end
end
