# encoding: UTF-8
require File.dirname(__FILE__) + "/../spec_helper"

describe SessionsController do
  describe "#create" do
    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
    end

    it "should create user from omniauth hash w/o info node" do
      request.env["omniauth.auth"] = {
        "provider" => "test",
        "uid" => "123456",
        "credentials" => {
          "token" => "123456",
          "secret" => "geheim"
        },
        "info" => nil
      }

      expect { get :create }.to change { User.all.count }.from(0).to(1)

      response.should redirect_to(root_path)
    end

    it "should redirect to back url" do
      get :create, ref: '/mypath'

      response.should redirect_to('/mypath')
    end

    it "should only redirect to own host" do
      get :create, ref: 'http://twitter.com/path'

      response.should redirect_to('/')
    end
  end
end
