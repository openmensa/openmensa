# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Ical feeds" do
  let(:canteen) do
    c = create(:canteen, :with_meals, name: "Test Canteen")
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 2.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 3.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 4.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 5.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 6.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 7.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 8.days)
    c.days << create(:day, :with_unordered_meals, canteen: c, date: Time.zone.today + 9.days)
    c.save!
    c
  end

  describe "GET /ical/:id/:slug.ics" do
    it "returns a calendar with the next 7 days" do
      get "/ical/#{canteen.id}/any-slug.ics"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(%r{text/calendar})
      expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"test-canteen.ics\"")

      calendar = Icalendar::Calendar.parse(response.body)
      expect(calendar.size).to eq 1

      calendar.first.events.tap do |events|
        expect(events.size).to eq 7
        expect(events[0].dtstart).to eq Icalendar::Values::Date.new(Time.zone.today)
        expect(events[1].dtstart).to eq Icalendar::Values::Date.new(Time.zone.today + 1.day)
        expect(events[6].dtstart).to eq Icalendar::Values::Date.new(Time.zone.today + 6.days)
      end
    end
  end
end
