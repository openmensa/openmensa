require 'spec_helper'

describe Api::V2::MealsController do
  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:canteen) { FactoryGirl.create :canteen_with_meals }
    before        { canteen }

    it "should answer with a list" do
      get :index, canteen_id: canteen.id, format: :json
      response.status.should == 200

      json.should be_an(Array)
      json.should have(6).item
    end

    it "should answer with a list of meal nodes" do
      get :index, canteen_id: canteen.id, format: :json
      response.status.should == 200

      json[0].should == {
        id: canteen.meals.first.id,
        name: canteen.meals.first.name,
        category: canteen.meals.first.category,
        prices: {
          students: canteen.meals.first.price_student,
          employees: canteen.meals.first.price_employee,
          pupils: canteen.meals.first.price_pupil,
          others: canteen.meals.first.price_other
        },
        notes: canteen.meals.first.notes.map(&:name)
      }.as_json
    end

    context "meal node" do
      let(:meal)    { FactoryGirl.create :meal_with_notes }
      let(:canteen) { meal.day.canteen }

      it "should include notes" do
        get :index, canteen_id: canteen.id, format: :json
        response.status.should == 200

        json[0]['notes'].should == meal.notes.map(&:name)
      end
    end
  end
end
