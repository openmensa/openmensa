# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe CanteenActivationController, type: :controller do
  describe '#create' do
    let(:canteen) { FactoryBot.create :canteen, state: 'archived' }
    before do
      post :create, params: {canteen_id: canteen.id}
    end
    subject { response }

    context 'as anonymous' do
      its(:status) { should eq 401 }
    end
  end

  describe '#destroy' do
    let(:canteen) { FactoryBot.create :canteen }
    before do
      delete :destroy, params: {canteen_id: canteen.id}
    end
    subject { response }

    context 'as anonymous' do
      its(:status) { should eq 401 }
    end
  end
end
