# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe MenuController do
  let(:user) { create(:user) }

  before do
    set_current_user user
  end

  describe "#show" do
    it "with invalid date" do
      get :show, params: {date: "A16"}

      expect(response).to have_http_status :not_found
    end
  end
end
