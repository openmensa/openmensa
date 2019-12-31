# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

describe 'Authentication', type: :feature do
  describe 'Login' do
    it 'should login using Twitter' do
      visit root_path
      click_link 'Anmelden'
      click_link 'Twitter'

      expect(page.body).to include('Mein Profil')
    end

    it 'should login using GitHub' do
      visit root_path
      click_link 'Anmelden'
      click_link 'GitHub'

      expect(page.body).to include('Mein Profil')
    end
  end

  describe 'Logout' do
    before :each do
      login FactoryBot.create(:identity)
    end

    it 'should sign off a user if signed in' do
      visit root_path
      click_link 'Abmelden'

      expect(page.body).to_not include 'Mein Profil'
    end
  end
end
