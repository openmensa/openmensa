# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe UsersController do
  let(:user) { FactoryGirl.create :user }

  describe "#show" do
    before { user }

    context "as anonymous" do
      it "should not be accessible" do
        get :show, id: user.id

        response.status.should == 401
      end
    end

    context "as user" do
      it "should be allow access to my profile" do
        set_current_user user
        get :show, id: user.id

        response.status.should == 200
      end
    end

    context "as admin" do
      it "should not be accessible" do
        set_current_user FactoryGirl.create(:admin)
        get :show, id: user.id

        response.status.should == 200
      end
    end
  end

  describe "#update" do
    before { user }

    context "as anonymous" do
      it "should not be accessible" do
        put :update, id: user.id, user: { user_name: 'Bobby' }

        response.status.should == 401
      end
    end

    context "as user" do
      it "should be allow to update to my profile" do
        set_current_user user
        put :update, id: user.id, user: { user_name: 'Bobby' }

        response.status.should == 302
      end
    end

    context "as admin" do
      it "should not be accessible" do
        set_current_user FactoryGirl.create(:admin)
        put :update, id: user.id, user: { user_name: 'Bobby' }

        response.status.should == 302
      end
    end
  end
end
