# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe "Favorites:" do
  context "User" do
    let(:user) { create(:user) }
    let(:canteen) { create(:canteen) }
    let(:canteen2) { create(:canteen) }
    let(:favorite) { create(:favorite, canteen:, user:) }
    let(:favorite2) { create(:favorite, canteen: canteen2, user:) }

    before do
      login_as user
    end

    it "can favorite a canteen" do
      visit canteen_path(canteen)

      click_on "Als Favorit markieren"

      expect(user).to have_favorite(canteen)
      expect(page).to have_link "Favorit entfernen"
    end

    it "can delete a favorite" do
      favorite

      expect(user).to have_favorite(canteen)

      visit canteen_path(canteen)

      click_on "Favorit entfernen"

      expect(user).not_to have_favorite(canteen)
      expect(page).to have_link "Als Favorit markieren"
    end

    it "can list its favorites" do
      favorite
      favorite2

      click_on "Mein Profil"
      click_on "Favoriten"

      expect(page).to have_link favorite.canteen.name
      expect(page).to have_link favorite2.canteen.name
    end

    it "can access favorite via start page directly" do
      favorite

      visit root_path
      click_on "OpenMensa" # we are on the menu page, lets open the start page

      expect(page).to have_content("Meine Favoriten")

      click_on favorite.canteen.name

      expect(page).to have_content favorite.canteen.name
      expect(page).to have_current_path canteen_path(favorite.canteen), ignore_query: true
    end

    it "is redirected to canteen page on one favorite" do
      favorite

      visit root_path

      expect(page).to have_current_path canteen_path(favorite.canteen), ignore_query: true

      expect(page).to have_content favorite.canteen.name
    end

    context "with previous set favorites" do
      before { favorite; favorite2 }

      it "is redirected to menu page if start page is open directly" do
        visit root_path

        expect(page).to have_current_path menu_path, ignore_query: true

        expect(page).to have_content(canteen.name)
        expect(page).to have_link("Mehr zu #{canteen.name}")
        expect(page).to have_content(canteen2.name)
        expect(page).to have_link("Mehr zu #{canteen2.name}")
      end

      it "is possible to open menu page from start page" do
        visit root_path
        click_on "OpenMensa" # we are on the menu page, lets open the start page

        expect(page).to have_current_path root_path, ignore_query: true

        expect(page).to have_link("Menü-Übersicht über alle Favoriten")

        click_on "Menü-Übersicht über alle Favoriten"

        expect(page).to have_current_path menu_path, ignore_query: true
      end
    end
  end

  context "anonymous" do
    let(:canteen) { create(:canteen) }

    it "has not favorite link on canteen page" do
      visit canteen_path(canteen)

      expect(page).to have_no_link "Als Favorit markieren"
    end

    it "has a start page without favorite menu" do
      visit root_path

      expect(page).to have_no_content("Meine Favoriten")
    end
  end
end
