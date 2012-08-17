# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe UsersController do
  describe "#show" do
    let(:user) { FactoryGirl.create :user }
    before { user }

    it "should not allow unauthorized access by anonymous" do
      get :show, id: user.id

      response.status.should == 401
    end
  end
end
