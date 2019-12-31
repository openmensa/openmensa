# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe 'Authentication', type: :feature do
  describe 'Login' do
    it 'logins using Twitter' do
      visit root_path
      click_link 'Anmelden'
      click_link 'Twitter'

      expect(page.body).to include('Mein Profil')
    end

    it 'logins using GitHub' do
      visit root_path
      click_link 'Anmelden'
      click_link 'GitHub'

      expect(page.body).to include('Mein Profil')
    end
  end

  describe 'Logout' do
    before do
      login FactoryBot.create(:identity)
    end

    it 'signs off a user if signed in' do
      visit root_path
      click_link 'Abmelden'

      expect(page.body).not_to include 'Mein Profil'
    end
  end
end
