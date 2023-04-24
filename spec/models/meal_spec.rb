# frozen_string_literal: true

require "spec_helper"

describe Meal do
  let(:meal) { create(:meal) }

  it { is_expected.not_to accept_values_for(:name, "", nil) }
  it { is_expected.not_to accept_values_for(:category, "", nil) }
  it { is_expected.not_to accept_values_for(:day, nil) }

  describe "#prices" do
    it "only contains set values" do
      meal.update(price_student: 1.7,
        price_employee: nil,
        price_other: 2.7,
        price_pupil: nil)
      expect(meal.prices).to eq student: 1.7, other: 2.7
    end

    it "can contain all values" do
      meal.update(price_student: 1.7,
        price_employee: 3.37,
        price_other: 2.7,
        price_pupil: 1.89)
      expect(meal.prices).to eq student: 1.7, other: 2.7, employee: 3.37, pupil: 1.89
    end
  end

  describe "#prices=" do
    it "ignores empty hashes" do
      meal.prices = {}
      expect(meal).not_to be_changed
    end

    it "updates given roles" do
      meal.update(price_student: 1.7,
        price_employee: nil,
        price_other: 2.7,
        price_pupil: nil)
      meal.prices = {employee: 1.89, other: nil}
      expect(meal.price_student).to eq 1.7
      expect(meal.price_employee).to eq 1.89
      expect(meal.price_pupil).to be_nil
      expect(meal.price_other).to be_nil
      expect(meal).to be_changed
    end
  end

  describe "#notes=" do
    it "clears notes list" do
      meal.notes << create(:note)
      meal.notes << create(:note)
      expect(meal.notes.size).to eq 2
      meal.notes = []
      expect(meal.notes.size).to be_zero
    end

    it "adds new notes" do
      expect(meal.notes.size).to eq 0
      meal.notes = %w[vegan vegetarisch]
      expect(meal.notes.size).to eq 2
      expect(meal.notes.map(&:name)).to match %w[vegan vegetarisch]
    end

    it "removes old notes" do
      meal.notes << note = create(:note)
      oldname = note.name
      expect(meal.notes.size).to eq 1
      meal.notes = ["#{oldname}2"]
      expect(meal.notes.size).to eq 1
      expect(meal.notes.first.name).to eq("#{oldname}2")
    end
  end
end
