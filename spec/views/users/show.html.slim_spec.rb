# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "users/show.html.slim" do
  let(:user) { FactoryGirl.create :user }

  before do
    controller.stub(:current_user) { User.new }
    assign(:user, user)

    user.identities.create! FactoryGirl.attributes_for(:identity, provider: 'github')
    user.identities.create! FactoryGirl.attributes_for(:identity, provider: 'twitter')

    render
  end

  it "should not show add identity button if all providers are bound" do
    rendered.should_not include("Identität hinzufügen")
  end
end
