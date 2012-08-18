# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "canteens/index.html.haml" do
  let(:user) { FactoryGirl.create :user }
  let(:canteens) {[
    FactoryGirl.create(:canteen),
    FactoryGirl.create(:canteen)
  ]}
  it "should list canteens" do
    assign(:user, user)
    assign(:canteens, canteens)

    render

    rendered.should include(canteens[0].name)
    rendered.should include(canteens[1].name)
  end
end
