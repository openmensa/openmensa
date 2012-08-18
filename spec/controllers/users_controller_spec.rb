# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe UsersController do
  let(:user) { FactoryGirl.create :user }

  describe "#show" do
    before { user }

    it "should not allow unauthorized access by anonymous" do
      get :show, id: user.id

      response.status.should == 401
    end
  end

  describe "#update" do
    before { user }

    it "should not be accessible by anonymous" do
      put :update, id: user.id, user_name: 'Bobby'

      response.status.should == 401
    end
  end
end
