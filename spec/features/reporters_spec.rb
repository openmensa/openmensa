# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Reporters: ', type: :feature do
  let!(:canteen) { FactoryGirl.create :canteen }

  it 'should be able to register a intereseted canteen' do
    visit root_path

    click_on 'Melde die Mensa als gewünscht'

    fill_in 'Name', with: 'Meine Liebligsmensa'
    fill_in 'Stadt / Region', with: 'Hamburg'
    click_on 'Mensa als gewünscht eintragen'

    expect(page).to have_content 'Die Mensa wurde erfolgreich als gewünscht gespeichert.'
    expect(page).to have_content 'Meine LiebligsmensaHamburg'
  end

  context 'with a previous created canteen' do
    let!(:canteen) { FactoryGirl.create :canteen, state: 'wanted', name: 'Meine Liebligsmensa', city: 'Hamburg'}

    it 'should see this canteen when registering an intereseted canteen' do
      visit root_path

      click_on 'Melde die Mensa als gewünscht'
      expect(page).to have_content 'Meine LiebligsmensaHamburg'
    end
  end

  it 'should be able to report an issues for a canteen' do
    pending 'todo'
    visit canteen_path(canteen)

    click_on 'Fehler melden'

    fill_in 'Mitteilung', with: 'Die Preisinformationen werden nicht mehr korrekt abgetrennt!'
    click_on 'Fehlerbereit senden'
  end

  it 'shoulb be able to report correct canteen meta data' do
    pending 'todo'
    visit canteen_path(canteen)

    click_on 'Daten korrigieren'

    fill_in 'Address', with: 'Neue Straße 4, 33024 Halsleben'
    fill_in 'Telefon', with: '0384 5833 005'
    click_on 'Fehlerbereit senden'
    expect(page).to have_content('Dein Korrekturhinweis wurde an den Mensaverantwortlichen weitergeleitet.')
  end
end
