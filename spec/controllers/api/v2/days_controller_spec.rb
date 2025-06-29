# frozen_string_literal: true

require "spec_helper"

describe Api::V2::DaysController do
  render_views

  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:day) { create(:day) }
    let(:canteen) { day.canteen }

    before { day }

    it "answers with a list" do
      get :index, format: :json, params: {canteen_id: canteen.id}
      expect(response).to have_http_status(:ok)

      expect(json).to be_an(Array)
      expect(json.size).to eq(1)
    end

    it "answers with a list of day nodes" do
      get :index, format: :json, params: {canteen_id: canteen.id}
      expect(response).to have_http_status(:ok)

      expect(json[0]).to eq({
        date: day.date.iso8601,
        closed: day.closed,
      }.as_json)
    end

    context "&start" do
      let(:today) { create(:today, closed: true) }
      let(:canteen) { today.canteen }
      let(:tomorrow) { create(:tomorrow, canteen:) }
      let(:yesterday) { create(:yesterday, canteen:) }

      before do
        today && tomorrow && yesterday
        create(:day, canteen:, date: yesterday.date - 1)
        create(:day, canteen:, date: yesterday.date - 2)
        create(:day, canteen:, date: tomorrow.date + 1)
      end

      it "defaults to today if not given" do
        get :index, format: :json, params: {canteen_id: canteen.id}

        expect(json).to have(3).items
        expect(json[0]["date"]).to eq(today.date.iso8601)
        expect(json[1]["date"]).to eq(tomorrow.date.iso8601)
        expect(json[2]["date"]).to eq((tomorrow.date + 1).iso8601)
      end
    end
  end

  describe "GET show" do
    let(:day) { create(:day) }
    let(:canteen) { day.canteen }

    before { canteen }

    it "answers with day" do
      get :show, format: :json,
        params: {canteen_id: canteen.id, id: day.to_param}

      expect(response).to have_http_status(:ok)

      expect(json).to eq({
        date: day.date.iso8601,
        closed: day.closed,
      }.as_json)
    end
  end
end
