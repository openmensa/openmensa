# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Profile page" do
  before do
    visit root_path
    click_link "Anmelden"
    click_link "Twitter"
    click_link "Profil"
  end

  it "should allow user to change name and email" do
    page.should have_content("Name")
    page.should have_content("E-Mail")

    fill_in "Name", with: "Boby Short"
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    find_field('Name').value.should == 'Boby Short'
    find_field('E-Mail').value.should == 'boby@altimos.de'
  end

  it "should raise error when user tries to update with empty name" do
    page.should have_content("Name")
    page.should have_content("E-Mail")

    fill_in "Name", with: ""
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    page.should have_content("muss ausgefüllt werden")
    find_field('Name').value.should == ''
    find_field('E-Mail').value.should == 'boby@altimos.de'
  end

  it "should allow user to add an identity" do
    click_link "Identität hinzufügen"

    expect { click_link "GitHub" }.to change { Identity.all.count }.from(1).to(2)

    Identity.last.provider.should == "github"

    current_path.should == user_path(1)
    page.should have_content("GitHub Identität hinzugefügt.")
  end

  it "should allow user to remove an identity" do
    click_link "Identität hinzufügen"
    click_link "GitHub"

    expect { click_link "Twitter Identität entfernen" }.to change {
      Identity.all.count }.from(2).to(1)

    Identity.first.provider.should == "github"

    page.should have_content("Twitter Identität entfernt.")
  end
end
