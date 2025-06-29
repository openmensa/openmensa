# frozen_string_literal: true

require_relative "../../spec_helper"
require_dependency "message"

describe "common/_canteen_actions.html.slim" do
  subject(:page) { Capybara.string(rendered) }

  let(:rendered) do
    allow(controller).to receive(:current_user).and_return(owner)
    render partial: "canteen_actions", locals: {canteen:}
  end

  let(:owner) { create(:developer) }
  let(:parser) { create(:parser, user: owner) }
  let!(:source) { create(:source, parser:, canteen:) }
  let(:canteen) { create(:canteen) }

  it "contains a link to edit the canteen" do
    expect(page).to have_link("Mensa bearbeiten")
  end

  it "contains a link to deactivate the canteen" do
    expect(page).to have_link("Mensa außer Betrieb nehmen")
  end

  context "with deactivate canteen" do
    let(:canteen) { create(:canteen, state: "archived") }

    it "contains a link to activate the canteen" do
      expect(page).to have_link("Mensa in Betrieb nehmen")
    end
  end

  it "contains a link to the canteen meal page" do
    expect(page).to have_link("Mensa anzeigen")
  end

  context "with feed for canteen" do
    let(:source) { create(:source, canteen:, parser:) }
    let!(:feed) { create(:feed, name: "debug", source:) }

    it "contains a link to fetch the feed manual" do
      expect(page).to have_link('Feed "debug" abrufen')
    end

    it "contains a link to see messages of that feed" do
      expect(page).to have_link('Protokoll für Feed "debug" anzeigen')
    end

    it "contains a link to the canteen feed" do
      expect(page).to have_link("Feed-URL öffnen")
      page.find(:link, "Feed-URL öffnen").tap do |link|
        expect(link[:href]).to eq feed.url
      end
    end
  end
end
