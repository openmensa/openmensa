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
end
