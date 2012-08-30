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

      it 'should add days with meals entries' do
        pending
      end
      it 'should add prices for meals' do
        pending
      end
      it 'should add correct notes for meals' do
        pending
      end
      it 'should add closed days entries' do
        pending
      end
      it 'should update last_fetch_at and not last_changed_at' do
        pending
      end
    end
    context 'with old data' do
      it 'should allow to close the canteen on given days' do
        pending
      end
      it 'should allow to reopen a canteen on given days' do
        pending
      end
      it 'should add new meals' do
        pending
      end
      it 'should drop disappeared meals' do
        pending
      end
      it 'should update changed meals' do
        pending
      end
      it 'should not update last_changed_at on unchanged meals' do
        pending
      end
      it 'should update last_fetch_at and not last_changed_at' do
        pending
      end
    end
  end
end
