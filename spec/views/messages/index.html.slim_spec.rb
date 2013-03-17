# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../lib/open_mensa.rb'
require File.dirname(__FILE__) + "/../../spec_helper"
require 'message'

describe "messages/index.html.slim" do
  let(:user) { FactoryGirl.create :user }
  let(:canteen) { FactoryGirl.create(:canteen, user: user) }
  let(:messages) {[
    FactoryGirl.create(:feedInvalidUrlError, canteen: canteen),
    FactoryGirl.create(:feedFetchError, canteen: canteen),
    FactoryGirl.create(:feedValidationError, canteen: canteen, kind: :invalid_xml)
  ]}

  before do
    controller.stub(:current_user) { User.new }
    assign(:user, user)
    assign(:canteen, canteen)
    assign(:messages, messages)

    render
  end

  it "should list canteens with their messages" do
    rendered.should include(canteen.name)
    rendered.should include(messages[1].code.to_s)
    rendered.should include(messages[1].message)
    rendered.should include(messages[2].version.to_s)
    rendered.should include(messages[2].message)
  end
end
