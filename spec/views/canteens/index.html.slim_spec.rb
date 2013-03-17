# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "canteens/index.html.slim" do
  let(:user) { FactoryGirl.create :user }
  let(:canteens) {[
    FactoryGirl.create(:canteen),
    FactoryGirl.create(:canteen)
  ]}

  before do
    controller.stub(:current_user) { User.new }
    assign(:user, user)
    assign(:canteens, canteens)

    render
  end

  it "should list canteens" do
    rendered.should include(canteens[0].name)
    rendered.should include(canteens[1].name)
  end
end
