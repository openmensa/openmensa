# encoding: UTF-8
require File.dirname(__FILE__) + '/../../../lib/open_mensa.rb'
require File.dirname(__FILE__) + '/../../spec_helper'
require 'message'

describe 'messages/index.html.slim', type: :view do
  let(:user) { FactoryGirl.create :user }
  let(:parser) { FactoryGirl.create :parser, user: user }
  let(:source) { FactoryGirl.create :source, parser: parser }
  let(:canteen) { source.canteen }
  let(:messages) {
    [
      FactoryGirl.create(:feedInvalidUrlError, canteen: canteen),
      FactoryGirl.create(:feedFetchError, canteen: canteen),
      FactoryGirl.create(:feedValidationError, canteen: canteen, kind: :invalid_xml)
    ]
  }

  before do
    allow(controller).to receive(:current_user) { User.new }
    assign(:user, user)
    assign(:canteen, canteen)
    assign(:messages, messages)

    render
  end

  it 'should list canteens with their messages' do
    expect(rendered).to include(canteen.name)
    expect(rendered).to include(messages[1].code.to_s)
    expect(rendered).to include(messages[1].message)
    expect(rendered).to include(messages[2].version.to_s)
    expect(rendered).to include(messages[2].message)
  end
end
