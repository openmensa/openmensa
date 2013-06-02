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
    let(:owner) { canteen.user}
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

    context 'should return update information' do
      let(:successfull_json) do
        {
          'status' => 'ok',
          'days' => {
            'added'   => 1,
            'updated' => 0
          },
          'meals' => {
            'added'   => 3,
            'updated' => 4,
            'removed' => 5
          }
        }
      end

      before do
        updater.should_receive(:update).and_return true
        updater.should_receive(:added_days).at_least(:once).and_return 1
        updater.should_receive(:updated_days).at_least(:once).and_return 0
        updater.should_receive(:added_meals).at_least(:once).and_return 3
        updater.should_receive(:updated_meals).at_least(:once).and_return 4
        updater.should_receive(:removed_meals).at_least(:once).and_return 5
      end

      it 'and render them for canteen owner' do
        set_current_user owner
        get :fetch, id: canteen.id, format: :json

        response.status.should == 200
        response.content_type.should == 'application/json'

        json.should == successfull_json

        assigns(:result).should == json
      end

      it 'and not render them for normal user' do
        get :fetch, id: canteen.id, format: :json

        response.status.should == 200
        response.content_type.should == 'application/json'

        json.should == successfull_json

        assigns(:result).should == { 'status' => 'ok' }
      end
    end

    context 'should return occured errors' do
      let(:feed_fetch_error) do
        FeedFetchError.create(canteen: canteen,
                                message: 'Could not fetch',
                                code: 404)
      end
      before do
        updater.should_receive(:update).and_return false
        updater.should_receive(:errors).at_least(:once).and_return do
          [ feed_fetch_error ]
        end
      end

      let(:json_error) do
        {
          'status' => 'error',
          'errors' => [
            {
              'type' => 'feed_fetch_error',
              'message' => 'Could not fetch',
              'code' => 404
            }
          ]
        }
      end

      it 'and render them for canteen owner' do
        set_current_user owner
        get :fetch, id: canteen.id, format: :json

        response.status.should == 200
        response.content_type.should == 'application/json'

        json.should == json_error

        assigns(:result).should == {
          'status' => 'error',
          'errors' => [ feed_fetch_error ]
        }
      end

      it 'and not render them for normal users' do
        get :fetch, id: canteen.id, format: :json

        response.status.should == 200
        response.content_type.should == 'application/json'

        json.should == json_error

        assigns(:result).should == { 'status' => 'error'}
      end
    end

    it 'should only allow one fetch per minute' do
      OpenMensa::Updater.rspec_reset
      updater.should_not_receive(:update)
      canteen.update_attribute :last_fetched_at, Time.zone.now - 14.minutes
      get :fetch, id: canteen.id, format: :json
      response.status.should == 429
    end

    it 'should updates from canteen owner every time' do
      set_current_user owner
      updater.should_receive(:update).and_return true
      canteen.update_attribute :last_fetched_at, Time.zone.now
      get :fetch, id: canteen.id, format: :json
      response.status.should == 200
    end
  end
end
