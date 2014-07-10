# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "canteens/index.html.slim", :type => :view do
  let(:user) { FactoryGirl.create :user }
  let(:canteens) {[
    FactoryGirl.create(:canteen),
    FactoryGirl.create(:canteen)
  ]}

  before do
    allow(controller).to receive(:current_user) { User.new }
    assign(:user, user)
    assign(:canteens, canteens)

    render
  end

  it "should list canteens" do
    expect(rendered).to include(canteens[0].name)
    expect(rendered).to include(canteens[1].name)
  end
end
