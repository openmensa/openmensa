require 'spec_helper'

describe Api::V2::MealsController do
  render_views

  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:canteen) { FactoryGirl.create :canteen, :with_unordered_meals }
    let(:day) { canteen.days.first! }
    before { canteen }

    it "should answer with a list" do
      get :index, canteen_id: canteen.id, day_id: day.to_param, format: :json
      response.status.should == 200

      json.should be_an(Array)
      json.should have(3).item
    end

    it "should answer with a list of meal nodes" do
      get :index, canteen_id: canteen.id, day_id: day.to_param, format: :json
      response.status.should == 200

      json[0].should == {
        id: day.meals.first.id,
        name: day.meals.first.name,
        category: day.meals.first.category,
        prices: {
          students: day.meals.first.price_student.try(:to_f),
          employees: day.meals.first.price_employee.try(:to_f),
          pupils: day.meals.first.price_pupil.try(:to_f),
          others: day.meals.first.price_other.try(:to_f)
        },
        notes: []
      }.as_json
    end

    context 'with unordered list of meals' do
      it 'should return list ordered' do
        get :index, canteen_id: canteen.id, day_id: day.to_param, format: :json
        response.status.should == 200

        json.map { |m| m['id'].to_i }.should == Meal.where(day: day).order(:pos).pluck(:id)
      end
    end

    context "meal node" do
      let(:meal) { FactoryGirl.create :meal, :with_notes }
      let(:day) { meal.day }
      let(:canteen) { meal.day.canteen }

      it "should include notes" do
        get :index, canteen_id: canteen.id, day_id: day.to_param, format: :json
        response.status.should == 200

        json[0]['notes'].should =~ meal.notes.map(&:name)
      end
    end
  end

  describe "GET canteen_meals" do
    let(:canteen) do
      c = FactoryGirl.create :canteen, :with_meals
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 2.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 3.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 4.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 5.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 6.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 7.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 8.days)
      c.days << FactoryGirl.create(:day, :with_unordered_meals, canteen: c, date: Date.today + 9.days)
      c.save!
      c
    end

    it "should answer with 7 days from now and their meals" do
      get :canteen_meals, canteen_id: canteen.id, format: :json
      response.status.should == 200
      json.should have(7).items
      json[0]['date'].should == (Date.today).iso8601
      json[1]['date'].should == (Date.today + 1.day).iso8601
      json[6]['date'].should == (Date.today + 6.day).iso8601
    end

    context "&start" do
      it "should answer with up to 7 days from given date and their meals" do
        get :canteen_meals, canteen_id: canteen.id, format: :json, start: (Date.today + 1.day).iso8601
        response.status.should == 200
        json.should have(7).items
        json[0]['date'].should == (Date.today + 1.day).iso8601
      end

      it "should answer with up to 7 days from given date and their meals (2)" do
        get :canteen_meals, canteen_id: canteen.id, format: :json, start: (Date.today + 5.day).iso8601
        response.status.should == 200
        json.should have(5).items
        json[0]['date'].should == (Date.today + 5.day).iso8601
        json[4]['date'].should == (Date.today + 9.day).iso8601
      end

      it 'should answer with a ordered list of meals' do
        get :canteen_meals, canteen_id: canteen.id, format: :json, start: (Date.today + 2.day).iso8601
        response.status.should == 200
        json.each do |day|
          dayModel = Day.find_by date: day['date'], canteen: canteen
          day['meals'].map { |m| m['id'] }.should == Meal.where(day: dayModel).order(:pos).pluck(:id)
        end
      end
    end
  end
end
