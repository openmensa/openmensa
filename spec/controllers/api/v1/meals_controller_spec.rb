require 'spec_helper'

describe Api::V1::MealsController do
  render_views

  let(:json) { JSON[response.body] }

  describe "GET index" do
    let(:canteen) { FactoryGirl.create :canteen }
    before do
      FactoryGirl.create :meal, day: FactoryGirl.create(:day, canteen: canteen, date: Time.zone.now - 2.day)
      FactoryGirl.create :meal, day: FactoryGirl.create(:yesterday, canteen: canteen)
      FactoryGirl.create :meal, day: FactoryGirl.create(:today, canteen: canteen)
      FactoryGirl.create :meal, day: FactoryGirl.create(:tomorrow, canteen: canteen)
      FactoryGirl.create :meal, day: FactoryGirl.create(:day, canteen: canteen, date: Time.zone.now + 2.day)
    end

    it "should return list of meals" do
      get :index, format: :json, cafeteria_id: canteen.id

      response.status.should == 200
      json.should be_an(Array)
      json.should have(5).item
    end

    context "a meal" do
      it "should have same representation as single resource" do
        get :index, format: :json, cafeteria_id: canteen.id

        meal = json[0]

        get :show, format: :json, cafeteria_id: canteen.id, id: meal["meal"]["id"]

        meal.should == JSON[response.body]
      end
    end
  end

  describe "GET show" do
    let(:canteen) { FactoryGirl.create :canteen }
    let(:meal)    { FactoryGirl.create :meal, day: FactoryGirl.create(:today, canteen: canteen) }

    it "should return a meal object" do
      get :show, format: :json, cafeteria_id: canteen.id, id: meal.id

      response.status.should == 200
      json.should be_an(Hash)

      json["meal"]["id"].should == meal.id
    end

    it "should include meal id" do
      get :show, format: :json, cafeteria_id: canteen.id, id: meal.id
      json["meal"]["id"].should == meal.id
    end

    it "should include date as UTC timestamp" do
      get :show, format: :json, cafeteria_id: canteen.id, id: meal.id
      json["meal"]["date"].should == meal.date.to_time.iso8601
    end
  end
end
