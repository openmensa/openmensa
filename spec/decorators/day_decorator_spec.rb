# frozen_string_literal: true

require "spec_helper"

describe DayDecorator do
  describe "#as_ics_event" do
    subject(:event) do
      decorator.as_ics_event
    end

    let(:day) { create(:day, date: Date.new(2026, 4, 22)) }
    let(:decorator) { day.decorate }

    before do
      create(
        :meal,
        day:,
        category: "Hauptgerichte",
        name: "Pasta",
        pos: 1,
        price_student: 2.50,
        price_employee: 4.20,
        price_pupil: nil,
        price_other: nil,
        notes: %w[vegan spicy],
      )
      create(
        :meal,
        day:,
        category: "Hauptgerichte",
        name: "Curry",
        pos: 2,
        price_student: nil,
        price_employee: nil,
        price_pupil: nil,
        price_other: nil,
      )
      create(
        :meal,
        day:,
        category: "Salat",
        name: "Beilagensalat",
        pos: 3,
        price_student: nil,
        price_employee: nil,
        price_pupil: nil,
        price_other: 1.90,
      )
    end

    it "sets dtstart and dtend to the decorated day date" do
      expect(event.dtstart).to eq Icalendar::Values::Date.new(day.date)
      expect(event.dtend).to eq Icalendar::Values::Date.new(day.date)
    end

    it "formats the description with categories, meals and prices" do
      expect(event.description.to_s).to eq <<~DESC
        Hauptgerichte:
        - Pasta (2,50 €, 4,20 €)
          * vegan
          * spicy
        - Curry

        Salat:
        - Beilagensalat (1,90 €)

      DESC
    end

    it "sets the summary to the canteen name" do
      expect(event.summary).to eq day.canteen.name
    end
  end
end
