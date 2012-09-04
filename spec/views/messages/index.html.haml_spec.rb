# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../lib/open_mensa.rb'
require File.dirname(__FILE__) + "/../../spec_helper"

describe "messages/index.html.haml" do
  let(:user) { FactoryGirl.create :user }
  let(:canteens) {[
    FactoryGirl.create(:canteen, user: user),
    FactoryGirl.create(:canteen, user: user),
    FactoryGirl.create(:canteen, user: user)
  ]}
  let(:messages) {[
    FactoryGirl.create(:feedInvalidUrlError, canteen: canteens[0]),
    FactoryGirl.create(:feedFetchError, canteen: canteens[0]),
    FactoryGirl.create(:feedValidationError, canteen: canteens[0], kind: :invalid_xml),
    FactoryGirl.create(:feedUrlUpdatedInfo, canteen: canteens[1])
  ]}
  it "should list canteens with their messages" do
    assign(:user, user)
    assign(:messages, messages)

    render

    rendered.should include(canteens[0].name)
    rendered.should include(messages[1].code.to_s)
    rendered.should include(messages[1].message)
    rendered.should include(messages[2].version.to_s)
    rendered.should include(messages[2].message)

    rendered.should include(canteens[1].name)
    rendered.should include(messages[3].old_url)
    rendered.should include(messages[3].new_url)
  end

  it "should not list canteens without messages" do
    assign(:user, user)
    assign(:messages, messages)

    render

    rendered.should_not include(canteens[2].name)
  end
end
