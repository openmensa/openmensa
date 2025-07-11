# frozen_string_literal: true

require "spec_helper"

describe "Authentication" do
  describe "Login" do
    it "logins using Twitter" do
      visit root_path
      click_on "Anmelden"
      click_on "Twitter"

      expect(page).to have_content "Abmelden"
    end

    it "logins using GitHub" do
      visit root_path
      click_on "Anmelden"
      click_on "GitHub"

      expect(page).to have_content "Abmelden"
    end
  end

  describe "Logout" do
    before do
      login create(:identity)
    end

    it "signs off a user if signed in" do
      visit root_path
      click_on "Abmelden"

      expect(page).to have_no_content "Abmelden"
    end
  end
end
