# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Favorites: " do
  context 'User' do
    let(:user) { FactoryGirl.create :user }
    let(:canteen) { FactoryGirl.create :canteen, user: user }
    let(:favorite) { FactoryGirl.create :favorite, canteen: canteen, user: user }
    let(:favorite2) { FactoryGirl.create :favorite, user: user }

    before do
      login_as user
    end

    it 'can favorite a canteen' do
      visit canteen_path(canteen)

      click_on "Als Favorit markieren"

      user.should have_favorite(canteen)
      page.should have_link 'Favorit entfernen'
    end

    it 'can delete a favorite' do
      favorite

      user.should have_favorite(canteen)

      visit canteen_path(canteen)

      click_on 'Favorit entfernen'

      user.should_not have_favorite(canteen)
      page.should have_link 'Als Favorit markieren'
    end

    it 'can list its favorites' do
      favorite
      favorite2

      click_on 'Mein Profil'
      click_on 'Favoriten'

      page.should have_link favorite.canteen.name
      page.should have_link favorite2.canteen.name
    end
  end

  context 'anonymous' do
    let(:canteen) { FactoryGirl.create :canteen }

    it 'should have not favorite link on canteen page' do
      visit canteen_path(canteen)

      page.should_not have_link 'Als Favorit markieren'
    end
  end
end
