# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"

describe SessionsController do
  describe "#create" do
    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    end

    it "creates user from omniauth hash w/o info node" do
      request.env["omniauth.auth"] = {
        "provider" => "test",
        "uid" => "123456",
        "credentials" => {
          "token" => "123456",
          "secret" => "geheim"
        },
        "info" => nil
      }

      expect do
        get :create, params: {provider: "test"}
      end.to change(User, :count).from(0).to(1)

      expect(response).to redirect_to(root_path)
    end

    it "redirects to back url" do
      get :create, params: {provider: "twitter", ref: "/mypath"}

      expect(response).to redirect_to("/mypath")
    end

    it "only redirects to own host" do
      get :create, params: {provider: "twitter", ref: "http://twitter.com/path"}

      expect(response).to redirect_to("/")
    end
  end
end
