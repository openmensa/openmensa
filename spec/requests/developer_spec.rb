# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Profile page" do
  let(:developer) { FactoryGirl.create :developer }

  before do
    login_as developer
    click_on "Profil"
  end

  it "should allow to add a new mensa feed" do
    click_on "Meine Mensen"
    click_on "Neuen Mensa hinzufügen"

    fill_in "Feed-Url", with: "http://example.org/canteens.xml"
    fill_in "Name", with: "Test-Mensa"
    fill_in "Adresse", with: "Essensweg 34, 12345 Hunger, Deutschland"
    click_on "Hinzufügen"

    page.should have_content 'Der Mensa wurde erfolgreich hinzugefügt.'
  end
end
