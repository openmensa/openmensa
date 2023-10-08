# frozen_string_literal: true

require_relative "../../spec_helper"

describe "canteens/show" do
  let(:user) { create(:user) }
  let(:canteen) { create(:canteen) }

  before do
    assign(:user, user)
    assign(:canteen, canteen)
    assign(:date, Time.zone.now.to_date)

    allow(view).to receive(:current_user) { user }
  end

  it "contains canteen name" do
    render
    expect(rendered).to include(canteen.name)
  end

  context "with deactived canteen" do
    it "contains a deactivation info" do
      canteen.update_attribute :state, "archived"
      render
      expect(rendered).to match(/#{canteen.name}.*\(Außer Betrieb\)/)
      expect(rendered).to include("Mensa ist außer Betrieb")
    end
  end

  context "without meals" do
    it "lists information about missing meal" do
      render

      expect(rendered).to include("keine Angebote")
    end
  end

  context "on closed day" do
    let(:day) { create(:day, :closed) }
    let(:canteen) { day.canteen }

    it "shows a closed notice" do
      render

      expect(rendered).to include("geschlossen")
    end
  end

  context "with a meal" do
    let(:day) { create(:today, canteen:) }
    let(:meal) { create(:meal, day:) }

    before do
      meal
    end

    it "lists names of category" do
      render
      expect(rendered).to include(meal.category)
    end

    it "includes prices of meal" do
      meal.prices = {student: 1.22, other: 2.20, employee: 1.7}
      meal.save!

      render

      expect(rendered).to include("Studierende")
      expect(rendered).to include("1,22 €")
      expect(rendered).to include("Mitarbeiter")
      expect(rendered).to include("1,70 €")
      expect(rendered).to include("Gäste")
      expect(rendered).to include("2,20 €")
      expect(rendered).not_to include("Schüler")
    end

    it "includes notes of meal" do
      meal.notes = %w[vegan vegetarisch]

      render

      expect(rendered).to include("vegan")
      expect(rendered).to include("vegetarisch")
    end
  end

  context "with meals" do
    let(:day) { create(:today, :with_unordered_meals, canteen:) }

    before { day }

    it "renders an ordered list of meals" do
      render

      meal_positions = []
      day.meals.order(:pos).each do |meal|
        meal_positions << rendered.index(meal.name)
      end

      expect(meal_positions).to eq(meal_positions.sort)
    end
  end

  it "prints up-to-date on canteens fetched in the last 24 hour" do
    canteen.update_attribute :last_fetched_at, 4.hours.ago
    render

    expect(rendered).to include("Daten aktuell")
  end

  it "prints a warning on canteens fetched earlier then 24 hour ago" do
    canteen.update_attribute :last_fetched_at, 25.hours.ago
    render
    expect(rendered).to include("Aktualisierung notwendig")
  end

  it "prints error on never fetched canteens" do
    canteen.update_attribute :last_fetched_at, nil
    render
    expect(rendered).to include("Noch keine Daten")
  end
end
