# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require_dependency 'message'

describe "common/_canteen_actions.html.slim" do
  let(:owner) { FactoryGirl.create :user }
  let(:canteen) { FactoryGirl.create(:canteen, user: owner) }
  let(:render_partial) do
    render partial: 'canteen_actions', \
      locals: { canteen: canteen}
  end

  it 'should contain a link to the canteen feed' do
    render_partial
    rendered.should include(canteen.url)
  end

  it 'should cantain a link to edit the canteen' do
    render_partial
    rendered.should include('Mensa bearbeiten')
  end

  it 'should cantain a link to view the canteen\' messages' do
    render_partial
    rendered.should include('Mensa-Mitteilungen')
  end
end
