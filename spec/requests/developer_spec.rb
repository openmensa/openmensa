# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe "Profile page" do
  let(:developer) { FactoryGirl.create :developer }

  before do
    login_as developer
    click_on "Profil"
  end

  it "should allow to add a new canteen feed" do
    click_on "Meine Mensen"
    click_on "Neuen Mensa hinzufügen"

    fill_in "Feed-Url", with: "http://example.org/canteens.xml"
    fill_in "Name", with: "Test-Mensa"
    fill_in "Adresse", with: "Essensweg 34, 12345 Hunger, Deutschland"
    click_on "Hinzufügen"

    page.should have_content 'Der Mensa wurde erfolgreich hinzugefügt.'
  end

  it "should allow to edit own canteens" do
    canteen = FactoryGirl.create :canteen, user_id: developer.id
    click_on "Meine Mensen"
    click_on "Mensa bearbeiten"

    new_url = "http://example.org/canteens.xml"
    new_name = "Test-Mensa"
    new_address = "Essensweg 34, 12345 Hunger, Deutschlandasd"
    fill_in "Feed-Url", with: new_url
    fill_in "Name", with: new_name
    fill_in "Adresse", with: new_address
    click_on "Speichern"

    canteen.reload

    canteen.url.should == new_url
    canteen.name.should == new_name
    canteen.address.should == new_address


    page.should have_content 'Mensa gespeichert.'
  end
end
