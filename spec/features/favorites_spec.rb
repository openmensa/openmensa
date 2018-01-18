# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Favorites: ', type: :feature do
  context 'User' do
    let(:user) { FactoryBot.create :user }
    let(:canteen) { FactoryBot.create :canteen }
    let(:canteen2) { FactoryBot.create :canteen }
    let(:favorite) { FactoryBot.create :favorite, canteen: canteen, user: user }
    let(:favorite2) { FactoryBot.create :favorite, canteen: canteen2, user: user }

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
      click_on 'OpenMensa' # we are on the menu page, lets open the start page

      expect(page).to have_content('Meine Favoriten')

      click_on favorite.canteen.name

      expect(page).to have_content favorite.canteen.name
      expect(current_path).to eq canteen_path(favorite.canteen)
    end

    it 'is redirected to canteen page on one favorite' do
      favorite

      visit root_path

      expect(current_path).to eq canteen_path(favorite.canteen)

      expect(page).to have_content favorite.canteen.name
    end

    context 'with previous set favorites' do
      before { favorite; favorite2 }

      it 'should be redirected to menu page if start page is open directly' do
        visit root_path

        expect(current_path).to eq menu_path

        expect(page).to have_content(canteen.name)
        expect(page).to have_link("Mehr zu #{canteen.name}")
        expect(page).to have_content(canteen2.name)
        expect(page).to have_link("Mehr zu #{canteen2.name}")
      end

      it 'should be possible to open menu page from start page' do
        visit root_path
        click_on 'OpenMensa' # we are on the menu page, lets open the start page

        expect(current_path).to eq root_path

        expect(page).to have_link("Menü-Übersicht über alle Favoriten")

        click_on 'Menü-Übersicht über alle Favoriten'

        expect(current_path).to eq menu_path
      end
    end
  end

  context 'anonymous' do
    let(:canteen) { FactoryBot.create :canteen }

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
