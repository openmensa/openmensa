# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Authentication" do
  describe "Login" do
    it "should login using twitter" do
      visit root_path
      click_link "Anmelden"
      click_link "Twitter"

      page.should have_content("Bob Example")
    end

    it "should login using github" do
      visit root_path
      click_link "Anmelden"
      click_link "GitHub"

      page.should have_content("Bob Example")
    end
  end

  describe "Logout" do
    before :each do
      login FactoryGirl.create(:identity)
    end

    it "should sign off a user if signed in" do
      visit root_path
      click_link "Abmelden"

      User.current.should == User.anonymous
    end
  end
end
