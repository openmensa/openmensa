# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe CanteenActivationController, type: :controller do
  describe '#create' do
    let(:canteen) { FactoryGirl.create :disabled_canteen }
    before do
      post :create, canteen_id: canteen.id
    end
    subject { response }

    context 'as anonymous' do
      its(:status) { should eq 401 }
    end
  end

  describe '#destroy' do
    let(:canteen) { FactoryGirl.create :canteen }
    before do
      delete :destroy, canteen_id: canteen.id
    end
    subject { response }

    context 'as anonymous' do
      its(:status) { should eq 401 }
    end
  end
end
