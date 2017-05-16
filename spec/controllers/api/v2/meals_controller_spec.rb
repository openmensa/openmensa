require 'spec_helper'

describe Api::V2::MealsController, type: :controller do
  render_views

  let(:json) { JSON.parse response.body }

  describe 'GET index' do
    let(:canteen) { FactoryGirl.create :canteen, :with_unordered_meals }
    let(:day) { canteen.days.first! }
    before { canteen }

    it 'should answer with a list' do
      get :index, format: :json,
        params: {canteen_id: canteen.id, day_id: day.to_param}

      expect(response.status).to eq(200)

      expect(json).to be_an(Array)
      expect(json.size).to eq(3)
    end

    it 'should answer with a list of meal nodes' do
      get :index, format: :json,
        params: {canteen_id: canteen.id, day_id: day.to_param}

      expect(response.status).to eq(200)

      expect(json[0]).to eq({
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
      }.as_json)
    end

    context 'with unordered list of meals' do
      it 'should return list ordered' do
        get :index, format: :json,
          params: {canteen_id: canteen.id, day_id: day.to_param}

        expect(response.status).to eq(200)

        expect(json.map {|m| m['id'].to_i }).to eq(Meal.where(day: day).order(:pos).pluck(:id))
      end
    end

    context 'meal node' do
      let(:meal) { FactoryGirl.create :meal, :with_notes }
      let(:day) { meal.day }
      let(:canteen) { meal.day.canteen }

      it 'should include notes' do
        get :index, format: :json,
          params: {canteen_id: canteen.id, day_id: day.to_param}

        expect(response.status).to eq(200)

        expect(json[0]['notes'].sort).to match(meal.notes.map(&:name))
      end
    end
  end

  describe 'GET canteen_meals' do
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

    it 'should answer with 7 days from now and their meals' do
      get :canteen_meals, format: :json, params: {canteen_id: canteen.id}
      expect(response.status).to eq(200)
      expect(json.size).to eq(7)
      expect(json[0]['date']).to eq((Date.today).iso8601)
      expect(json[1]['date']).to eq((Date.today + 1.day).iso8601)
      expect(json[6]['date']).to eq((Date.today + 6.day).iso8601)
    end

    context '&start' do
      it 'should answer with up to 7 days from given date and their meals' do
        get :canteen_meals, format: :json,
          params: {canteen_id: canteen.id, start: (Date.today + 1.day).iso8601}

        expect(response.status).to eq(200)
        expect(json.size).to eq(7)
        expect(json[0]['date']).to eq((Date.today + 1.day).iso8601)
      end

      it 'should answer with up to 7 days from given date and their meals (2)' do
        get :canteen_meals, format: :json,
          params: {canteen_id: canteen.id, start: (Date.today + 5.day).iso8601}

        expect(response.status).to eq(200)
        expect(json.size).to eq(5)
        expect(json[0]['date']).to eq((Date.today + 5.day).iso8601)
        expect(json[4]['date']).to eq((Date.today + 9.day).iso8601)
      end

      it 'should answer with a ordered list of meals' do
        get :canteen_meals, format: :json,
          params: {canteen_id: canteen.id, start: (Date.today + 2.day).iso8601}

        expect(response.status).to eq(200)
        json.each do |day|
          dayModel = Day.find_by date: day['date'], canteen: canteen
          expect(day['meals'].map {|m| m['id'] }).to eq(Meal.where(day: dayModel).order(:pos).pluck(:id))
        end
      end
    end
  end
end
