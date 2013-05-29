# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe CanteensController do
  describe '#show' do
    let(:canteen) { FactoryGirl.create :canteen, :with_meals }

    it "should fetch canteen" do
      get :show, id: canteen.id

      assigns(:canteen).should == canteen
    end

    it "canteen's meals for today" do
      get :show, id: canteen.id

      assigns(:meals).should == canteen.meals.where(date: Time.zone.now.to_date)
    end

    it 'should fetch meals for given date parameter' do
      get :show, id: canteen.id, date: Time.zone.now.to_date + 1.day

      assigns(:meals).should == canteen.meals.where(date: Time.zone.now.to_date + 1.day)
    end
  end

  describe '#update' do
    let(:canteen) { FactoryGirl.create :canteen, :with_meals }
    let(:user) { FactoryGirl.create :user }

    it 'should not be accessible by anonymous' do
      patch :update, user_id: canteen.user.id, id: canteen.id, canteen: { name: 'NewName' }

      canteen.reload
      canteen.name.should_not == 'NewName'

      response.status.should == 401
    end
  end

  describe '#fetch' do
    let(:canteen) { FactoryGirl.create :canteen, :with_meals }
    let(:updater) { OpenMensa::Updater.new(canteen) }
    let(:json) { JSON.parse response.body }

    before do
      updater
      OpenMensa::Updater.should_receive(:new).with(canteen).and_return updater
    end

    it 'should run openmensa updater' do
      updater.should_receive(:update).and_return true
      get :fetch, id: canteen.id, format: :json

      response.status.should == 200
    end
  end
end
