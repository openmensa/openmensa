# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "users/show.html.haml" do
  let(:user) { FactoryGirl.create :user }
  it "should not show add identity button if all providers are bound" do
    assign(:user, user)

    user.identities.create! FactoryGirl.attributes_for(:identity, provider: 'github')
    user.identities.create! FactoryGirl.attributes_for(:identity, provider: 'twitter')

    render

    rendered.should_not include("Identität hinzufügen")
  end
end
