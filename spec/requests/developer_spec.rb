# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"
require_dependency 'message'

describe "Profile page" do
  let(:developer) { FactoryGirl.create :developer }
  let(:canteen) { FactoryGirl.create :canteen, user_id: developer.id }

  before do
    login_as developer
    click_on "Profil"
  end

  it "should allow to add a new canteen feed" do
    click_on "Meine Mensen"
    click_on "Neue Mensa hinzufügen"

    fill_in "Feed-Url", with: "http://example.org/canteens.xml"
    fill_in "Name", with: "Test-Mensa"
    fill_in "Adresse", with: "Essensweg 34, 12345 Hunger, Deutschland"
    select 'Standard', from: 'Frühste Abrufstunde'
    click_on "Hinzufügen"

    page.should have_content 'Der Mensa wurde erfolgreich hinzugefügt.'
  end

  it "should allow to edit own canteens" do
    canteen
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

  it "should allow to set fetch_hour for meal" do
    canteen
    click_on "Meine Mensen"
    click_on "Mensa bearbeiten"

    select "9 Uhr", from: 'Frühste Abrufstunde'
    click_on "Speichern"

    canteen.reload

    canteen.fetch_hour.should == 9
  end

  it "should allow to set fetch_hour to default" do
    canteen
    click_on "Meine Mensen"
    click_on "Mensa bearbeiten"

    select "Standard", from: 'Frühste Abrufstunde'
    click_on "Speichern"

    canteen.reload

    canteen.fetch_hour.should be_nil
  end

  it "should allow to view own messages" do
    message = FactoryGirl.create :feedValidationError, canteen: canteen, kind: :invalid_xml
    click_on "Statusmitteilungen"

    page.should have_content message.canteen.name
    page.should have_content message.message
  end

  it "should allow to activate (daily) report mails" do
    developer.send_reports?.should be_false

    check "Sende Error-Reports per Mail (maximal täglich)"
    click_on "Speichern"

    developer.reload

    developer.send_reports?.should be_true
  end

  it "should allow to deactivate (daily) report mails" do
    developer.send_reports = true
    developer.save!

    click_on "Profil"
    uncheck "Sende Error-Reports per Mail (maximal täglich)"
    click_on "Speichern"

    developer.reload

    developer.send_reports?.should be_false
  end
end
