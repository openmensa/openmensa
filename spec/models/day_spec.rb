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

    it "is stored and loaded as gregorian date" do
      pending "Rails doesn't correctly parse SQL dates in gregorian calendar"

      day = create(:day, date: "1500-02-28")
      # expect(day.date).to be_gregorian
      expect(day.date).to eq Date.new(1500, 2, 28, Date::GREGORIAN)
      day.reload
      # expect(day.date).to be_gregorian
      expect(day.date).to eq Date.new(1500, 2, 28, Date::GREGORIAN)
    end
  end

  describe "#canteen" do
    it "is not valid without a canteen" do
      day = build(:day, canteen: nil)
      expect(day).not_to be_valid
    end
  end

  describe ".parse" do
    subject(:parsed) { Day.parse(value) }

    let(:value) { "2025-02-28" }

    it "parses into a working day date" do
      expect(parsed).to eq Date.new(2025, 2, 28)
    end

    context "with pre-gregorian date" do
      let(:value) { "1500-02-28" }

      it { is_expected.to be_gregorian }
      it { is_expected.to eq Date.new(1500, 2, 28, Date::GREGORIAN) }
    end

    context "with invalid pre-gregorian date" do
      let(:value) { "1500-02-29" }

      it "is parsed and rejected as a pre-gregorian date" do
        expect { parsed }.to raise_error(Date::Error)
      end
    end

    context "with invalid date (1)" do
      let(:value) { "1509" }

      it "raises a Date::Error" do
        expect { parsed }.to raise_error(Date::Error)
      end
    end

    context "with invalid date (2)" do
      let(:value) { "A63" }

      it "raises a Date::Error" do
        expect { parsed }.to raise_error(Date::Error)
      end
    end
  end

  it "has unique date per canteen" do
    same_day = build(:day, canteen: day.canteen, date: day.date)
    expect(same_day).not_to be_valid
  end
end
