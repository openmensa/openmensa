# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "canteens/show.html.haml" do
  let(:user) { FactoryGirl.create :user }
  let(:canteen) { FactoryGirl.create(:canteen) }

  before do
    assign(:user, user)
    assign(:canteen, canteen)
    assign(:date, Time.zone.now.to_date)
  end

  it "should contain canteen name" do
    render
    rendered.should include(canteen.name)
  end

  context 'without meals' do
    it 'should list information about missing meal' do
      render

      rendered.should include('keine Angebote')
    end
  end

  context 'on closed day' do
    let(:day) { FactoryGirl.create(:closed_day) }
    let(:canteen) { day.canteen }

    it "should show a closed notice" do
      render

      rendered.should include('geschlossen')
    end
  end

  context 'with meals' do
    let(:day) { FactoryGirl.create(:today, canteen: canteen) }
    let(:meal) { FactoryGirl.create(:meal, day: day) }
    before do
      meal
    end

    it 'should list names of category' do
      render
      rendered.should include(meal.category)
    end

    it 'should include name of meal' do
      render
      rendered.should include(meal.category)
    end

    it 'should include prices of meal' do
      meal.prices = { student: 1.22, other: 2.20, employee: 1.7 }
      meal.save!

      render

      rendered.should include('Student')
      rendered.should include('1,22 €')
      rendered.should include('Angestellte')
      rendered.should include('1,70 €')
      rendered.should include('Gäste')
      rendered.should include('2,20 €')
      rendered.should_not include("Schüler")
    end

    it 'should include notes of meal' do
      meal.notes = [ 'vegan', 'vegetarisch' ]

      render

      rendered.should include('vegan')
      rendered.should include('vegetarisch')
    end
  end
end
