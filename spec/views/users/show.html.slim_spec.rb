# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "users/show.html.slim", :type => :view do
  let(:user) { FactoryGirl.create :user }

  before do
    allow(controller).to receive(:current_user) { User.new }
    assign(:user, user)

    user.identities.create! FactoryGirl.attributes_for(:identity, provider: 'github')
    user.identities.create! FactoryGirl.attributes_for(:identity, provider: 'twitter')

    render
  end

  it "should not show add identity button if all providers are bound" do
    expect(rendered).not_to include("Identität hinzufügen")
  end
end
