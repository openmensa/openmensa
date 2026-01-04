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
