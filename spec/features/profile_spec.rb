# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Profile page" do
  let(:user) { FactoryGirl.create :user }

  before do
    login_as user
    click_link "Profil"
  end

  it "should allow user to change name and email" do
    page.should have_content("Name")
    page.should have_content("E-Mail")

    fill_in "Name", with: "Boby Short"
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    page.should have_content("Profil gespeichert.")

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

    expect { click_link "GitHub" }.to change { Identity.all.count }.by(1)

    Identity.last.provider.should == "github"

    current_path.should == user_path(user)
    page.should have_content("GitHub Identität hinzugefügt.")
  end

  it "should allow user to remove an identity", js: true do
    click_link "Identität hinzufügen"
    click_link "GitHub"

    expect { click_link "Twitter Identität entfernen" }.to change {
      Identity.all.count }.from(2).to(1)

    Identity.first.provider.should == "github"

    page.should have_content("Twitter Identität entfernt.")
  end
end
