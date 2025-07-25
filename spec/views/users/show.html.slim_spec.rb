# frozen_string_literal: true

require_relative "../../spec_helper"

describe "users/show" do
  let(:user) { create(:user) }

  let(:current_user) { user }

  before do
    allow(controller).to receive(:current_user) { current_user }
    allow(view).to receive(:current_user) { current_user }

    assign(:user, user)

    user.identities.create! attributes_for(:identity, provider: "github")
    user.identities.create! attributes_for(:identity, provider: "twitter")

    render
  end

  it "does not show add identity button if all providers are bound" do
    expect(rendered).not_to include("Identität hinzufügen")
  end
end
