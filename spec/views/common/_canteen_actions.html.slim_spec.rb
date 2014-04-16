# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require_dependency 'message'

describe "common/_canteen_actions.html.slim" do
  let(:owner) { FactoryGirl.create :user }
  let(:canteen) { FactoryGirl.create(:canteen, user: owner) }
  before do
    render partial: 'canteen_actions', \
      locals: { canteen: canteen}
  end
  subject { rendered }

  it 'should contain a link to the canteen feed' do
    rendered.should include(canteen.url)
    rendered.should include('Feed-URL öffen')
  end

  it 'should cantain a link to edit the canteen' do
    rendered.should include('Mensa bearbeiten')
  end

  it 'should cantain a link to deactivate the canteen' do
    rendered.should include('Mensa außer Betrieb nehmen')
  end

  context 'with deactivate canteen' do
    let(:canteen) { FactoryGirl.create(:disabled_canteen, user: owner) }
    it 'should cantain a link to activate the canteen' do
      rendered.should include('Mensa in Betrieb nehmen')
    end
  end

  it 'should cantain a link to view the canteen\' messages' do
    rendered.should include('Mensa-Mitteilungen')
  end

  it 'should contain a link to the canteen meal page' do
    rendered.should include('Mensa-Seite')
  end
end
