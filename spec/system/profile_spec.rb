# frozen_string_literal: true

require "spec_helper"

describe "Profile page" do
  let(:user) { create(:user) }

  before do
    login_as user
    click_link "Profil"
  end

  it "allows user to change name and email" do
    expect(page).to have_content("Name")
    expect(page).to have_content("E-Mail")

    fill_in "Name", with: "Boby Short"
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    expect(page).to have_content("Profil gespeichert.")

    expect(find_field("Name").value).to eq("Boby Short")
    expect(find_field("E-Mail").value).to eq("boby@altimos.de")
  end

  it "raises error when user tries to update with empty name" do
    expect(page).to have_content("Name")
    expect(page).to have_content("E-Mail")

    fill_in "Name", with: ""
    fill_in "E-Mail", with: "boby@altimos.de"
    click_on "Speichern"

    expect(page).to have_content("muss ausgefüllt werden")
    expect(find_field("Name").value).to eq("")
    expect(find_field("E-Mail").value).to eq("boby@altimos.de")
  end

  it "allows user to add an identity" do
    click_on "Identität hinzufügen"

    expect do
      click_on "GitHub"
      # Ensure we're back on the profile page
      expect(page).to have_content "Meine Identitäten"
    end.to change(Identity, :count).by(1)

    expect(Identity.last.provider).to eq("github")

    expect(page).to have_current_path(user_path(user), ignore_query: true)
    expect(page).to have_content("GitHub Identität hinzugefügt.")
  end

  it "allows user to remove an identity" do
    click_on "Identität hinzufügen"
    click_on "GitHub"

    # Ensure we're back on the profile page
    expect(page).to have_content "Meine Identitäten"

    expect do
      click_on "Twitter Identität entfernen"
      # Ensure we're back on the profile page
      expect(page).to have_content "Meine Identitäten"
    end.to change(Identity, :count).from(2).to(1)

    expect(Identity.first.provider).to eq("github")

    expect(page).to have_content("Twitter Identität entfernt.")
  end
end
