# frozen_string_literal: true

require "spec_helper"

describe Day do
  let(:day) { create(:day) }

  describe "#date" do
    it "is not valid without a data" do
      day = build(:day, date: nil)
      expect(day).not_to be_valid
    end

    it "is not valid with an empty data" do
      day = build(:day, date: "")
      expect(day).not_to be_valid
    end
  end

  describe "#canteen" do
    it "is not valid without a canteen" do
      day = build(:day, canteen: nil)
      expect(day).not_to be_valid
    end
  end

  it "has unique date per canteen" do
    same_day = build(:day, canteen: day.canteen, date: day.date)
    expect(same_day).not_to be_valid
  end
end
