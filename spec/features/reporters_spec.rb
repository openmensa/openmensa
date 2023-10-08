# frozen_string_literal: true

require "spec_helper"

describe "Reporters:" do
  let!(:canteen) { create(:canteen) }
  let(:parser) { create(:parser) }
  let(:source) { create(:source, parser:, canteen:) }

  it "is able to report an issues for a canteen" do
    expect(Feedback.count).to eq 0
    visit canteen_path(canteen)

    click_on "Rückmeldung geben"

    fill_in "Kurzbeschreibung", with: "Die Preisinformationen werden nicht mehr korrekt abgetrennt!"
    click_on "Rückmeldung absenden"
    expect(page).to have_content("Deine Feedback wurde erfolgreich weitergeleitet.")
    expect(Feedback.count).to eq 1
  end

  it "is able to report correct canteen meta data" do
    visit canteen_path(canteen)

    click_on "Daten korrigieren/ergänzen"

    fill_in "Adresse", with: "Neue Straße 4, 33024 Halsleben"
    fill_in "Telefon", with: "0384 5833 005"
    click_on "Korrekturvorschlag senden"
    expect(page).to have_content("Dein Korrekturhinweis wurde an den Mensaverantwortlichen weitergeleitet.")
  end

  it "is able to take maintainership for obsolete parser" do
    source
    parser.update maintainer_wanted: true
    visit canteen_path(canteen)

    click_on "Am Parser mitarbeiten"

    fill_in "Kurzbeschreibung", with: "Ich kann Python. Melde ich mal ich will mithelfen."
    click_on "Rückmeldung absenden"
    expect(page).to have_content("Deine Feedback wurde erfolgreich weitergeleitet.")
  end
end
