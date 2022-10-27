# frozen_string_literal: true

require "spec_helper"

describe Canteen, type: :model do
  let(:canteen) { create :canteen }

  it { is_expected.not_to accept_values_for(:name, nil, "") }
  it { is_expected.not_to accept_values_for(:state, nil, "", "test") }
  it { is_expected.to accept_values_for(:state, "new", "active", "empty", "archived") }

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
        canteen.update_attribute :last_fetched_at, Time.zone.now - 4.hours
      end

      it { is_expected.to eq :fetch_up_to_date }
    end

    context "when updated earlier than 24 hours ago" do
      before do
        canteen.update_attribute :last_fetched_at, Time.zone.now - 25.hours
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
