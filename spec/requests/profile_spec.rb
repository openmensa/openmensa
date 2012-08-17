# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Profile page" do
  it "should allow user to change name and email" do
    visit root_path
    click_link "Anmelden"
    click_link "Twitter"

    click_link "Mein Profil"

    page.should have_content("Name")
    page.should have_content("E-Mail")

    fill_in "Name", with: "Boby Short"
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    find_field('Name').value.should == 'Boby Short'
    find_field('E-Mail').value.should == 'boby@altimos.de'
  end

  it "should raise error when user tries to update with empty name" do
    visit root_path
    click_link "Anmelden"
    click_link "Twitter"

    click_link "Mein Profil"

    page.should have_content("Name")
    page.should have_content("E-Mail")

    fill_in "Name", with: ""
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    page.should have_content("muss ausgefüllt werden")
    find_field('Name').value.should == 'Bob Example'
    find_field('E-Mail').value.should == 'boby@altimos.de'
  end

  it "should allow user to remove an identity" do
    visit root_path
    click_link "Anmelden"
    click_link "Twitter"

    click_link "Profile"


  end
end
