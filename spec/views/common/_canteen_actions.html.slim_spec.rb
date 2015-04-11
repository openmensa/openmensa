# encoding: UTF-8
require File.dirname(__FILE__) + '/../../spec_helper'
require_dependency 'message'

describe 'common/_canteen_actions.html.slim', type: :view do
  let(:owner) { FactoryGirl.create :developer }
  let(:parser) { FactoryGirl.create :parser, user: owner }
  let!(:source) { FactoryGirl.create :source, parser: parser, canteen: canteen }
  let(:canteen) { FactoryGirl.create :canteen }
  subject do
    allow(controller).to receive(:current_user).and_return(owner)
    render partial: 'canteen_actions', \
           locals: {canteen: canteen}
    rendered
  end

  it 'should cantain a link to edit the canteen' do
    is_expected.to include('Mensa bearbeiten')
  end

  it 'should cantain a link to deactivate the canteen' do
    is_expected.to include('Mensa außer Betrieb nehmen')
  end

  context 'with deactivate canteen' do
    let(:canteen) { FactoryGirl.create(:disabled_canteen) }
    it 'should cantain a link to activate the canteen' do
      is_expected.to include('Mensa in Betrieb nehmen')
    end
  end

  it 'should contain a link to the canteen meal page' do
    is_expected.to include('Mensa-Seite')
  end

  context 'with feed for canteen' do
    let(:source) { FactoryGirl.create :source, canteen: canteen, parser: parser }
    let!(:feed) { FactoryGirl.create :feed, name: 'debug', source: source }

    it 'should contain a link to fetch the feed manual' do
      is_expected.to include('Feed debug abrufen')
    end

    it 'should contain a link to see messages of that feed' do
      is_expected.to include('Feed debug-Mitteilungen')
    end

    it 'should contain a link to the canteen feed' do
      is_expected.to include(feed.url)
      is_expected.to include('Feed debug öffnen')
    end
  end
end
