# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe CanteensController, :type => :controller do
  describe '#show' do
    let(:canteen) { FactoryGirl.create :canteen, :with_meals }

    it "should fetch canteen" do
      get :show, id: canteen.id

      expect(assigns(:canteen)).to eq canteen
    end

    it "canteen's meals for today" do
      get :show, id: canteen.id

      expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now)
    end

    it 'should fetch meals for given date parameter' do
      get :show, id: canteen.id, date: Time.zone.now.to_date + 1.day

      expect(assigns(:meals)).to eq canteen.meals.for(Time.zone.now.to_date + 1.day)
    end
  end

  describe '#update' do
    let(:canteen) { FactoryGirl.create :canteen, :with_meals }
    let(:user) { FactoryGirl.create :user }

    it 'should not be accessible by anonymous' do
      patch :update, user_id: canteen.user.id, id: canteen.id, canteen: { name: 'NewName' }

      canteen.reload
      expect(canteen.name).to_not eq 'NewName'

      expect(response.status).to eq 401
    end
  end

  describe '#fetch' do
    let(:canteen) { FactoryGirl.create :canteen, :with_meals, user: owner }
    let(:owner) { FactoryGirl.create :developer}
    let(:updater) { OpenMensa::Updater.new(canteen) }
    let(:json) { JSON.parse response.body }

    before do
      updater
      expect(OpenMensa::Updater).to receive(:new).with(canteen).and_return updater
    end

    it 'should run openmensa updater' do
      expect(updater).to receive(:update).and_return true
      get :fetch, id: canteen.id, format: :json

      expect(response.status).to eq 200
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
        expect(updater).to receive(:update).and_return true
        expect(updater).to receive(:added_days).at_least(:once).and_return 1
        expect(updater).to receive(:updated_days).at_least(:once).and_return 0
        expect(updater).to receive(:added_meals).at_least(:once).and_return 3
        expect(updater).to receive(:updated_meals).at_least(:once).and_return 4
        expect(updater).to receive(:removed_meals).at_least(:once).and_return 5
      end

      it 'and render them for canteen owner' do
        set_current_user owner
        get :fetch, id: canteen.id, format: :json

        expect(response.status).to eq  200
        expect(response.content_type).to eq 'application/json'

        expect(json).to eq successfull_json

        expect(assigns(:result)).to eq json
      end

      it 'and not render them for normal user' do
        get :fetch, id: canteen.id, format: :json

        expect(response.status). to eq 200
        expect(response.content_type).to eq 'application/json'

        expect(json).to eq successfull_json

        expect(assigns(:result)).to eq({ 'status' => 'ok' })
      end
    end

    context 'should return occured errors' do
      let(:feed_fetch_error) do
        FeedFetchError.create(canteen: canteen,
                                message: 'Could not fetch',
                                code: 404)
      end
      before do
        expect(updater).to receive(:update).and_return false
        expect(updater).to receive(:errors).at_least(:once) do
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

        expect(response.status).to eq 200
        expect(response.content_type).to eq 'application/json'

        expect(json).to eq json_error

        expect(assigns(:result)).to eq ({
          'status' => 'error',
          'errors' => [ feed_fetch_error ]
        })
      end

      it 'and not render them for normal users' do
        get :fetch, id: canteen.id, format: :json

        expect(response.status).to eq 200
        expect(response.content_type).to eq 'application/json'

        expect(json).to eq json_error

        expect(assigns(:result)).to eq({ 'status' => 'error'})
      end
    end

    it 'should only allow one fetch per minute' do
      expect(OpenMensa::Updater.new(canteen)).to_not receive(:update)
      canteen.update_attribute :last_fetched_at, Time.zone.now - 14.minutes
      get :fetch, id: canteen.id, format: :json
      expect(response.status).to eq 429
    end

    it 'should updates from canteen owner every time' do
      set_current_user owner
      expect(updater).to receive(:update).and_return true
      canteen.update_attribute :last_fetched_at, Time.zone.now
      get :fetch, id: canteen.id, format: :json
      expect(response.status).to eq 200
    end
  end
end
