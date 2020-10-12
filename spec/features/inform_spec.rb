# frozen_string_literal: true

require File.dirname(__FILE__) + "/../spec_helper"

describe "Inform", type: :feature do
  context "as a interessed user" do
    it "I want to contact" do
      visit root_path

      click_on "Kontakt"

      expect(page).to have_content "Kontakt"
      expect(page).to have_link_to "https://github.com/openmensa/openmensa"
      expect(page).to have_link_to "mailto:info@openmensa.org"
    end

    it "I want to find how openmensa works" do
      visit root_path

      click_on "Erfahre mehr über OpenMensa"

      expect(page).to have_content "openmensa.org"
      expect(page).to have_content "Community"
      expect(page).to have_content "Parser"
      expect(page).to have_content "Apps"
      expect(page).to have_link_to "mailto:info@openmensa.org"
    end

    it "I want to find how to contribute to openmensa" do
      visit root_path

      click_on "Arbeite mit an OpenMensa"

      expect(page).to have_content "Schreibe mit an Parsern"
      expect(page).to have_link_to "http://doc.openmensa.org/parsers/"
      expect(page).to have_link_to "https://github.com/mswart/openmensa-parsers"
      expect(page).to have_link_to "https://github.com/mswart/pyopenmensa"

      expect(page).to have_content "Apps für Smartphone"
      expect(page).to have_link_to "https://github.com/domoritz/open-mensa-android/"
      expect(page).to have_link_to "http://cooperrs.de/openmensa.html"

      expect(page).to have_content "Die Plattform selbst"
      expect(page).to have_link_to "https://github.com/openmensa/openmensa"
      expect(page).to have_link "RubyOnRails"
    end

    it "is able to see the list of interested canteens" do
      FactoryBot.create :canteen, state: "wanted",
                                  name: "Meine Liebligsmensa",
                                  city: "Hamburg"
      visit root_path

      click_on "Arbeite mit an OpenMensa"

      click_on "Liste der gewünschten Mensen"

      expect(page).to have_content /Meine Liebligsmensa\s+Hamburg/
    end

    it "I want to find how to support openmensa" do
      visit root_path

      click_on "Hilf mit bei OpenMensa"

      expect(page).to have_content "Verbreite OpenMensa"
      expect(page).to have_content "Dokumentiere und Antworte für OpenMensa"
      expect(page).to have_content "Programmiere mit an OpenMensa"
      expect(page).to have_content "Finde Mitstreiter"
      expect(page).to have_link_to "mailto:info@openmensa.org"
    end

    it "I want to follow openmensa's development" do
      visit root_path

      expect(page).to have_link_to "https://twitter.com/openmensa"
    end
  end
end
