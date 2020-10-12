# frozen_string_literal: true

require "spec_helper"

describe "API routing within", type: :routing do
  context "/api/v2" do
    let(:base) { "/api/v2" }

    it "routes /canteens to v2 canteen#index" do
      expect(get: "#{base}/canteens").to route_to(
        controller: "api/v2/canteens",
        action: "index",
        format: "json"
      )
    end

    it "routes /canteens/:id to v2 canteens#show" do
      expect(get: "#{base}/canteens/1").to route_to(
        controller: "api/v2/canteens",
        action: "show",
        format: "json",
        id: "1"
      )
    end

    it "routes /canteens/:canteen_id/days to v2 days#index" do
      expect(get: "#{base}/canteens/1/days").to route_to(
        controller: "api/v2/days",
        action: "index",
        format: "json",
        canteen_id: "1"
      )
    end

    it "routes /canteens/:canteen_id/days/:date to v2 days#show" do
      expect(get: "#{base}/canteens/1/days/2012-10-14").to route_to(
        controller: "api/v2/days",
        action: "show",
        format: "json",
        canteen_id: "1",
        id: "2012-10-14"
      )
    end

    it "routes /canteens/:canteen_id/days/:date/meals to v2 meals#index" do
      expect(get: "#{base}/canteens/1/days/2012-10-14/meals").to route_to(
        controller: "api/v2/meals",
        action: "index",
        format: "json",
        canteen_id: "1",
        day_id: "2012-10-14"
      )
    end

    it "routes /canteens/:canteen_id/days/:date/meals/:id to v2 meals#show" do
      expect(get: "#{base}/canteens/1/days/2012-10-14/meals/1").to route_to(
        controller: "api/v2/meals",
        action: "show",
        format: "json",
        canteen_id: "1",
        day_id: "2012-10-14",
        id: "1"
      )
    end
  end
end
