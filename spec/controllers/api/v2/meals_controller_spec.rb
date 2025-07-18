# frozen_string_literal: true

require "spec_helper"

describe Api::V2::MealsController do
  render_views

  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:canteen) { create(:canteen, :with_unordered_meals) }
    let(:day) { canteen.days.first! }

    before { canteen }

    it "answers with a list" do
      get :index, format: :json,
        params: {canteen_id: canteen.id, day_id: day.to_param}

      expect(response).to have_http_status(:ok)

      expect(json).to be_an(Array)
      expect(json.size).to eq(3)
    end

    it "answers with a list of meal nodes" do
      get :index, format: :json,
        params: {canteen_id: canteen.id, day_id: day.to_param}

      expect(response).to have_http_status(:ok)

      expect(json[0]).to eq({
        id: day.meals.first.id,
        name: day.meals.first.name,
        category: day.meals.first.category,
        prices: {
          students: day.meals.first.price_student.try(:to_f),
          employees: day.meals.first.price_employee.try(:to_f),
          pupils: day.meals.first.price_pupil.try(:to_f),
          others: day.meals.first.price_other.try(:to_f),
        },
        notes: [],
      }.as_json)
    end

    context "with unordered list of meals" do
      it "returns list ordered" do
        get :index, format: :json,
          params: {canteen_id: canteen.id, day_id: day.to_param}

        expect(response).to have_http_status(:ok)

        expect(json.map {|m| m["id"].to_i }).to eq(Meal.where(day:).order(:pos).pluck(:id))
      end
    end

    context "meal node" do
      let(:meal) { create(:meal, :with_notes) }
      let(:day) { meal.day }
      let(:canteen) { meal.day.canteen }

      it "includes notes" do
        get :index, format: :json,
          params: {canteen_id: canteen.id, day_id: day.to_param}

        expect(response).to have_http_status(:ok)

        expect(json[0]["notes"].sort).to match(meal.notes.map(&:name))
      end
    end
  end

  describe "GET canteen_meals" do
    let(:canteen) do
      c = create(:canteen, :with_meals)
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

    it "answers with 7 days from now and their meals" do
      get :canteen_meals, format: :json, params: {canteen_id: canteen.id}
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(7)
      expect(json[0]["date"]).to eq(Time.zone.today.iso8601)
      expect(json[1]["date"]).to eq((Time.zone.today + 1.day).iso8601)
      expect(json[6]["date"]).to eq((Time.zone.today + 6.days).iso8601)
    end

    context "&start" do
      it "answers with up to 7 days from given date and their meals" do
        get :canteen_meals, format: :json,
          params: {canteen_id: canteen.id, start: (Time.zone.today + 1.day).iso8601}

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(7)
        expect(json[0]["date"]).to eq((Time.zone.today + 1.day).iso8601)
      end

      it "answers with up to 7 days from given date and their meals (2)" do
        get :canteen_meals, format: :json,
          params: {canteen_id: canteen.id, start: (Time.zone.today + 5.days).iso8601}

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(5)
        expect(json[0]["date"]).to eq((Time.zone.today + 5.days).iso8601)
        expect(json[4]["date"]).to eq((Time.zone.today + 9.days).iso8601)
      end

      it "answers with a ordered list of meals" do
        get :canteen_meals, format: :json,
          params: {canteen_id: canteen.id, start: (Time.zone.today + 2.days).iso8601}

        expect(response).to have_http_status(:ok)
        json.each do |day|
          dayModel = Day.find_by(date: day["date"], canteen:)
          expect(day["meals"].pluck("id")).to eq(Meal.where(day: dayModel).order(:pos).pluck(:id))
        end
      end
    end
  end
end
