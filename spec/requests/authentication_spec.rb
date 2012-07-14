# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Authentication" do
  describe "Login" do
    xit "should login using Twitter" do
      visit root_path
      click_link "Anmelden"
      click_link "Twitter"

      page.should have_content("Bob Example")
    end

    xit "should login using GitHub" do
      visit root_path
      click_link "Anmelden"
      click_link "GitHub"

      page.should have_content("Bob Example")
    end
  end

  describe "Connect" do
    let(:user)     { FactoryGirl.create :user }
    let(:identity) { user.identities.first }

    xit "should add a new GitHub identity" do
      login_with identity

      user.identities.count.should == 1

      expect {
        visit root_path
        click_link "Mit GitHub verbinden"

      }.to change { user.identities.count }.from(1).to(2)

      user.identities.last.provider.should == "github"
    end
  end

  describe "Logout" do
    before :each do
      login FactoryGirl.create(:identity)
    end

    xit "should sign off a user if signed in" do
      visit root_path
      click_link "Abmelden"

      User.current.should == User.anonymous
    end
  end
end
