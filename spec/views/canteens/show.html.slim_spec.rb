# encoding: UTF-8
require File.dirname(__FILE__) + '/../../spec_helper'

describe 'canteens/show.html.slim', type: :view do
  let(:user) { FactoryBot.create :user }
  let(:canteen) { FactoryBot.create(:canteen) }

  before do
    assign(:user, user)
    assign(:canteen, canteen)
    assign(:date, Time.zone.now.to_date)

    allow(view).to receive(:current_user) { user }
  end

  it 'should contain canteen name' do
    render
    expect(rendered).to include(canteen.name)
  end

  context 'with deactived canteen' do
    it 'should contain a deactivation info' do
      canteen.update_attribute :state, 'archived'
      render
      expect(rendered).to match /#{canteen.name}.*\(Außer Betrieb\)/
      expect(rendered).to include('Mensa ist außer Betrieb')
    end
  end

  context 'without meals' do
    it 'should list information about missing meal' do
      render

      expect(rendered).to include('keine Angebote')
    end
  end

  context 'on closed day' do
    let(:day) { FactoryBot.create :day, :closed }
    let(:canteen) { day.canteen }

    it 'should show a closed notice' do
      render

      expect(rendered).to include('geschlossen')
    end
  end

  context 'with a meal' do
    let(:day) { FactoryBot.create(:today, canteen: canteen) }
    let(:meal) { FactoryBot.create(:meal, day: day) }
    before do
      meal
    end

    it 'should list names of category' do
      render
      expect(rendered).to include(meal.category)
    end

    it 'should include name of meal' do
      render
      expect(rendered).to include(meal.category)
    end

    it 'should include prices of meal' do
      meal.prices = {student: 1.22, other: 2.20, employee: 1.7}
      meal.save!

      render

      expect(rendered).to include('Studierende')
      expect(rendered).to include('1,22 €')
      expect(rendered).to include('Mitarbeiter')
      expect(rendered).to include('1,70 €')
      expect(rendered).to include('Gäste')
      expect(rendered).to include('2,20 €')
      expect(rendered).not_to include('Schüler')
    end

    it 'should include notes of meal' do
      meal.notes = %w(vegan vegetarisch)

      render

      expect(rendered).to include('vegan')
      expect(rendered).to include('vegetarisch')
    end
  end
  context 'with meals' do
    let(:day) { FactoryBot.create(:today, :with_unordered_meals, canteen: canteen) }
    before { day }
    it 'should render an ordered list of meals' do
      render

      mealPositions = []
      day.meals.order(:pos).each do |meal|
        mealPositions << rendered.index(meal.name)
      end

      expect(mealPositions).to eq(mealPositions.sort)
    end
  end

  it 'should print up-to-date on canteens fetched in the last 24 hour' do
    canteen.update_attribute :last_fetched_at, Time.zone.now - 4.hour
    render

    expect(rendered).to include('Daten aktuell')
  end

  it 'should print a warning on canteens fetched earlier then 24 hour ago' do
    canteen.update_attribute :last_fetched_at, Time.zone.now - 25.hour
    render
    expect(rendered).to include('Aktualisierung notwendig')
  end

  it 'should print error on never fetched canteens' do
    canteen.update_attribute :last_fetched_at, nil
    render
    expect(rendered).to include('Noch keine Daten')
  end
end
