# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe CanteensController do
  describe "#show" do
    let(:canteen) { create(:canteen, :with_meals) }

    it "fetches canteen" do
      get :show, params: {id: canteen.id}

      expect(assigns(:canteen)).to eq canteen
    end

    it "canteens meals for today" do
      get :show, params: {id: canteen.id}

      expect(assigns(:date)).to eq Time.zone.today
      expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now)
    end

    it "with invalid date" do
      get :show, params: {id: canteen.id, date: "A16"}

      expect(response).to have_http_status :not_found
    end

    it "fetches meals for given date parameter" do
      get :show, params: {id: canteen.id, date: 1.day.from_now}

      expect(assigns(:date)).to eq 1.day.from_now.to_date
      expect(assigns(:meals)).to eq canteen.meals.for(1.day.from_now)
    end

    context "with gaps between days" do
      let(:today) { Time.zone.today }
      let(:canteen) { create(:canteen) }

      before do
        create(:day, canteen:, date: today - 3)
        create(:day, canteen:, date: today + 5)
      end

      it "links the previous and next day" do
        get :show, params: {id: canteen.id}

        expect(assigns(:prev_date)).to eq today - 1
        expect(assigns(:next_date)).to eq today + 1
        expect(response.headers["Link"]).to include(
          %(<http://test.host/c/#{canteen.id}/#{today - 1}>; rel="prev"),
          %(<http://test.host/c/#{canteen.id}/#{today + 1}>; rel="next"),
        )
      end

      it "does not link beyond the first and last day" do
        get :show, params: {id: canteen.id, date: today - 3}

        expect(assigns(:prev_date)).to be_nil
        expect(response.headers["Link"]).not_to include('rel="prev"')

        get :show, params: {id: canteen.id, date: today + 5}

        expect(assigns(:next_date)).to be_nil
        expect(response.headers["Link"]).not_to include('rel="next"')
      end

      it "does not link days beyond the future limit" do
        create(:day, canteen:, date: today + Day::MAX_FUTURE + 1)

        get :show, params: {id: canteen.id, date: today + 5}

        expect(assigns(:next_date)).to be_nil
      end

      it "shows empty days in between" do
        get :show, params: {id: canteen.id, date: today + 1}

        expect(response).to have_http_status :ok
      end

      it "returns not found before the first day" do
        get :show, params: {id: canteen.id, date: today - 4}

        expect(response).to have_http_status :not_found
      end

      it "returns not found beyond the future limit" do
        get :show, params: {id: canteen.id, date: today + Day::MAX_FUTURE + 1}

        expect(response).to have_http_status :not_found
      end
    end

    context "without days" do
      let(:canteen) { create(:canteen) }

      it "shows today without links" do
        get :show, params: {id: canteen.id}

        expect(response).to have_http_status :ok
        expect(assigns(:prev_date)).to be_nil
        expect(assigns(:next_date)).to be_nil
      end

      it "returns not found for past days" do
        get :show, params: {id: canteen.id, date: Time.zone.yesterday}

        expect(response).to have_http_status :not_found
      end
    end

    context "with replaced canteen" do
      let(:replaced) { create(:canteen, state: "archived", replaced_by: canteen) }

      it "asdf" do
        get :show, params: {id: replaced.id}

        expect(assigns(:canteen)).to eq canteen

        expect(assigns(:date)).to eq Time.zone.today
        expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now)
      end
    end
  end

  describe "#update" do
    let(:canteen) { create(:canteen, :with_meals) }
    let(:user) { create(:user) }

    it "is not accessible by anonymous" do
      patch :update, params: {id: canteen.id, canteen: {name: "NewName"}}

      canteen.reload
      expect(canteen.name).not_to eq "NewName"

      expect(response).to have_http_status :unauthorized
    end
  end
end
