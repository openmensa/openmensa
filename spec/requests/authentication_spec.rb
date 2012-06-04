# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe "Authentication" do
  describe "Login" do
    it "should login user with valid credentials" do
      @identity = FactoryGirl.create(:identity)

      visit root_path

      click_link 'Log in'

      within 'form#login' do
        fill_in      "Login",    with: @identity.uid
        fill_in      "Password", with: @identity.password
        click_button "Log in"
      end

      page.should have_content("logged in")
    end

    it "should return to login form and show error when invalid credentials" do
      visit login_path
      within 'form#login' do
        fill_in      "Login",    with: 'wrong-id'
        fill_in      "Password", with: 'wrong-secret'
        click_button "Log in"
      end

      page.should have_content("Invalid login")
    end
  end

  describe "Logout" do
    before :each do
      @identity = FactoryGirl.create(:identity)
      login @identity
    end

    it "should sign off a user if signed in" do
      visit root_path

      click_link @identity.user.name
      click_link "Log out"

      User.current.should == User.anonymous
    end
  end
end
