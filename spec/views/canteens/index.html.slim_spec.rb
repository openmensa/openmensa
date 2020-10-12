# frozen_string_literal: true

require File.dirname(__FILE__) + "/../../spec_helper"

describe "canteens/index.html.slim", type: :view do
  let(:user) { FactoryBot.create :user }
  let(:canteens) do
    [
      FactoryBot.create(:canteen),
      FactoryBot.create(:canteen)
    ]
  end

  before do
    allow(controller).to receive(:current_user) { User.new }
    assign(:user, user)
    assign(:canteens, canteens)

    render
  end

  it "lists canteens" do
    expect(rendered).to include(canteens[0].name)
    expect(rendered).to include(canteens[1].name)
  end
end
