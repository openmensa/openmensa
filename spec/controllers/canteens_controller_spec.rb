# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe CanteensController, type: :controller do
  describe "#show" do
    let(:canteen) { FactoryBot.create :canteen, :with_meals }

    it "fetches canteen" do
      get :show, params: {id: canteen.id}

      expect(assigns(:canteen)).to eq canteen
    end

    it "canteens meals for today" do
      get :show, params: {id: canteen.id}

      expect(assigns(:date)).to eq Date.today
      expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now)
    end

    it "fetches meals for given date parameter" do
      get :show, params: {id: canteen.id, date: Time.zone.now + 1.day}

      expect(assigns(:date)).to eq (Time.zone.now + 1.day).to_date
      expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now + 1.day)
    end

    context "with replaced canteen" do
      let(:replaced) { FactoryBot.create :canteen, state: "archived", replaced_by: canteen }

      it "asdf" do
        get :show, params: {id: replaced.id}

        expect(assigns(:canteen)).to eq canteen

        expect(assigns(:date)).to eq Date.today
        expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now)
      end
    end
  end

  describe "#update" do
    let(:canteen) { FactoryBot.create :canteen, :with_meals }
    let(:user) { FactoryBot.create :user }

    it "is not accessible by anonymous" do
      patch :update, params: {id: canteen.id, canteen: {name: "NewName"}}

      canteen.reload
      expect(canteen.name).not_to eq "NewName"

      expect(response.status).to eq 401
    end
  end
end
