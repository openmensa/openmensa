# frozen_string_literal: true

require "spec_helper"

describe Day, type: :model do
  let(:day) { create(:day) }

  it { is_expected.not_to accept_values_for(:date, nil, "") }
  it { is_expected.not_to accept_values_for(:canteen, nil) }

  it "has unique date per canteen" do
    same_day = build(:day, canteen: day.canteen, date: day.date)
    expect(same_day).not_to be_valid
  end
end
