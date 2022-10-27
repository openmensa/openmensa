# frozen_string_literal: true

require_relative "../../spec_helper"
require_dependency "message"

describe "common/_canteen_actions.html.slim", type: :view do
  subject(:rendered) do
    allow(controller).to receive(:current_user).and_return(owner)
    render partial: "canteen_actions", locals: {canteen: canteen}
  end

  let(:owner) { create :developer }
  let(:parser) { create :parser, user: owner }
  let!(:source) { create :source, parser: parser, canteen: canteen }
  let(:canteen) { create :canteen }

  it "contains a link to edit the canteen" do
    expect(rendered).to include("Mensa bearbeiten")
  end

  it "contains a link to deactivate the canteen" do
    expect(rendered).to include("Mensa außer Betrieb nehmen")
  end

  context "with deactivate canteen" do
    let(:canteen) { create(:canteen, state: "archived") }

    it "contains a link to activate the canteen" do
      expect(rendered).to include("Mensa in Betrieb nehmen")
    end
  end

  it "contains a link to the canteen meal page" do
    expect(rendered).to include("Mensa-Seite")
  end

  context "with feed for canteen" do
    let(:source) { create :source, canteen: canteen, parser: parser }
    let!(:feed) { create :feed, name: "debug", source: source }

    it "contains a link to fetch the feed manual" do
      expect(rendered).to include("Feed debug abrufen")
    end

    it "contains a link to see messages of that feed" do
      expect(rendered).to include("Feed debug-Mitteilungen")
    end

    it "contains a link to the canteen feed" do
      expect(rendered).to include(feed.url)
      expect(rendered).to include("Feed debug öffnen")
    end
  end
end
