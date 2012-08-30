require File.dirname(__FILE__) + '/../../../lib/open_mensa.rb'
require 'spec_helper'
include LibXML

describe OpenMensa::Updater do
  let(:canteen) { FactoryGirl.create :canteen }
  let(:updater) { OpenMensa::Updater.new(canteen) }
  let(:today) { FactoryGirl.create :today, canteen: canteen }
  let(:document) { XML::Document.new }
  let(:root_element) { document.root = XML::Node.new('openmensa') }

  context "should reject" do
    it "non-xml data" do
      updater.validate(mock_content('feed_garbage.dat')).should be_false
    end
    it "well-formatted but non-valid xml data" do
      updater.validate(mock_content('feed_wellformated.xml')).should be_false
    end
    it "valid but non-openmensa xml data" do
      updater.validate(mock_content('carrier_ship.xml')).should be_false
    end
  end

  it "should return 1 on valid v1 openmensa xml feeds" do
    updater.validate(mock_content('canteen_feed.xml')).should == 1
  end
  it "should return 2 on valid v openmensa xml feeds" do
    updater.validate(mock_content('feed_v2.xml')).should == 2
  end

  context "with valid v2 feed" do
    it 'ignore empty feeds' do
      pending
    end
    context 'with new data' do
      it 'should add a new meals to a day' do
        meal_name = 'Essen 1'
        meal_category = 'Hauptgricht'

        root_element << meal = XML::Node.new('meal')
        meal << name = XML::Node.new('name')
        name << meal_name
        today.meals.size.should be_zero

        updater.addMeal(today, meal_category, meal)

        today.meals.size.should == 1
        today.meals.first.name.should == meal_name

        updater.should be_changed
      end

      it 'should add a new day with meals entries' do
        # data
        category1_name = 'Hauptgricht'
        category1_meal1_name = 'Essen 1'
        category1_meal2_name = 'Essen 2'

        category2_name = 'Beilagen'
        category2_meal1_name = 'Beilage 1'

        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = Time.zone.today.to_s

        day << category = XML::Node.new('category')
        category['name'] = category1_name
        category << meal = XML::Node.new('meal')
        meal << name = XML::Node.new('name')
        name << category1_meal1_name
        category << meal = XML::Node.new('meal')
        meal << name = XML::Node.new('name')
        name << category1_meal2_name

        day << category = XML::Node.new('category')
        category['name'] = category2_name
        category << meal = XML::Node.new('meal')
        meal << name = XML::Node.new('name')
        name << category2_meal1_name

        # starting check
        canteen.days.size.should be_zero

        updater.addDay(day)

        canteen.days.size.should == 1
        day = canteen.days.first
        day.meals.size.should == 3
        day.meals.order(:category).map(&:category).should == [category2_name, category1_name, category1_name]

        updater.should be_changed
      end

      it 'should add closed days entries' do
        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = Time.zone.today.to_s
        day << XML::Node.new('closed')

        # starting check
        canteen.days.size.should be_zero

        updater.addDay(day)

        canteen.days.size.should == 1
        day = canteen.days.first
        day.should be_closed
        day.meals.size.should be_zero

        updater.should be_changed
      end

      it 'should update last_fetch_at and not last_changed_at' do
        pending
      end
    end


    context 'with old data' do
      it 'should allow to close the canteen on given days' do
        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = today.date.to_s
        day << XML::Node.new('closed')
        meal = FactoryGirl.create :meal, day: today

        # starting check
        today.meals.size.should == 1
        today.should_not be_closed

        updater.updateDay(today, day)

        today.meals.size.should be_zero
        today.should be_closed

        updater.should be_changed
      end


     it 'should allow to reopen a canteen on given days' do
        # data
        category_name = 'Hauptessen'
        meal_name = 'Essen 1'

        # close our test day
        today.update_attribute :closed, true

        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = today.date.to_s
        day << category = XML::Node.new('category')
        category['name'] = category_name
        category << meal = XML::Node.new('meal')
        meal << name = XML::Node.new('name')
        name << meal_name

        # starting check
        today.meals.size.should == 0
        today.should be_closed

        updater.updateDay(today, day)

        today.meals.size.should == 1
        today.should_not be_closed

        updater.should be_changed
      end


      it 'should add new meals' do
        # data
        category_name = 'Hauptessen'
        meal_name = 'Essen 1'

        # close our test day
        meal = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = today.date.to_s
        day << category = XML::Node.new('category')
        category['name'] = meal.category
        category << newMeal = XML::Node.new('meal')
        newMeal << name = XML::Node.new('name')
        name << meal.name
        category['name'] = category_name
        category << newMeal = XML::Node.new('meal')
        newMeal << name = XML::Node.new('name')
        name << meal_name

        # starting check
        today.meals.size.should == 1

        updater.updateDay(today, day)

        today.meals.size.should == 2
        today.meals.map(&:name) == [meal.name, meal_name]

        updater.should be_changed
      end

      it 'should update changed meals' do
        # close our test day
        meal1 = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = today.date.to_s
        day << category = XML::Node.new('category')
        category['name'] = meal1.category
        category << newMeal = XML::Node.new('meal')
        newMeal << name = XML::Node.new('name')
        name << meal1.name

        # starting check
        today.meals.size.should == 1

        updater.updateDay(today, day)

        today.meals.size.should == 1
        today.meals.first.name.should == meal1.name
      end

      it 'should drop disappeared meals' do
        # close our test day
        meal1 = FactoryGirl.create :meal, day: today
        meal2 = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = today.date.to_s
        day << category = XML::Node.new('category')
        category['name'] = meal2.category
        category << newMeal = XML::Node.new('meal')
        newMeal << name = XML::Node.new('name')
        name << meal2.name

        # starting check
        today.meals.size.should == 2

        updater.updateDay(today, day)

        today.meals.size.should == 1
        today.meals.first.should == meal2

        updater.should be_changed
      end

      it 'should not update last_changed_at on unchanged meals' do
        # close our test day
        meal1 = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = XML::Node.new('day')
        day['date'] = today.date.to_s
        day << category = XML::Node.new('category')
        category['name'] = meal1.category
        category << newMeal = XML::Node.new('meal')
        newMeal << name = XML::Node.new('name')
        name << meal1.name

        # starting check
        today.meals.size.should == 1
        updated_at = meal1.updated_at

        updater.updateDay(today, day)

        today.meals.size.should == 1
        meal1.updated_at.should == updated_at
      end

      it 'should update last_fetch_at and not last_changed_at' do
        pending
      end
    end
  end
end
