# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe UsersController do
  let(:user) { create(:user) }

  describe "#show" do
    before { user }

    context "as anonymous" do
      it "is not accessible" do
        get :show, params: {id: user.id}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "as user" do
      it "is allow access to my profile" do
        set_current_user user
        get :show, params: {id: user.id}

        expect(response).to have_http_status(:ok)
      end
    end

    context "as admin" do
      it "is not accessible" do
        set_current_user create(:admin)
        get :show, params: {id: user.id}

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#update" do
    before { user }

    context "as anonymous" do
      it "is not accessible" do
        put :update, params: {id: user.id, user: {user_name: "Bobby"}}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "as user" do
      it "is allow to update to my profile" do
        set_current_user user
        put :update, params: {id: user.id, user: {user_name: "Bobby"}}

        expect(response).to have_http_status(:found)
      end
    end

    context "as admin" do
      it "is not accessible" do
        set_current_user create(:admin)
        put :update, params: {id: user.id, user: {user_name: "Bobby"}}

        expect(response).to have_http_status(:found)
      end
    end
  end
end
