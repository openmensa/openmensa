# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Favorites: ', type: :feature do
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

      click_on 'Als Favorit markieren'

      expect(user).to have_favorite(canteen)
      expect(page).to have_link 'Favorit entfernen'
    end

    it 'can delete a favorite' do
      favorite

      expect(user).to have_favorite(canteen)

      visit canteen_path(canteen)

      click_on 'Favorit entfernen'

      expect(user).not_to have_favorite(canteen)
      expect(page).to have_link 'Als Favorit markieren'
    end

    it 'can list its favorites' do
      favorite
      favorite2

      click_on 'Mein Profil'
      click_on 'Favoriten'

      expect(page).to have_link favorite.canteen.name
      expect(page).to have_link favorite2.canteen.name
    end

    it 'can access favorite via start page directly' do
      favorite

      visit root_path

      expect(page).to have_content('Meine Favoriten')

      click_on favorite.canteen.name

      expect(page).to have_content favorite.canteen.name
    end
  end

  context 'anonymous' do
    let(:canteen) { FactoryGirl.create :canteen }

    it 'should have not favorite link on canteen page' do
      visit canteen_path(canteen)

      expect(page).not_to have_link 'Als Favorit markieren'
    end

    it 'should have a start page without favorite menu' do
      visit root_path

      expect(page).not_to have_content('Meine Favoriten')
    end
  end
end
