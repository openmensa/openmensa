# encoding: UTF-8
require "spec_helper"

describe "API /status" do
  let(:client)    { FactoryGirl.create :client }
  let(:identity)  { FactoryGirl.create :identity }
  let(:user)      { identity.user }
  let(:auth_code) { Oauth2::AuthorizationCode.create! client: client, user: user }

  context "without authorization/authentication" do
    it "should return anonymous authentication type" do
      get "/api/status"

      response.should be_ok
      json = JSON[response.body]

      json["auth"]["type"].should == 'anonymous'
    end
  end

  context "with authorization code authentication" do
    xit "should can authorize as user with given access token as bearer token" do
      post "/oauth/token?" +
        [
          "grant_type=authorization_code",
          "client_id=#{client.identifier}",
          "client_secret=#{client.secret}",
          "code=#{auth_code.token}"
        ].join("&")

      tokens = JSON[response.body]
      access_token  = tokens["access_token"]
      refresh_token = tokens["refresh_token"]

      get "/api/status", {}, auth_bearer(access_token)

      response.should be_ok
      json = JSON[response.body]

      json["auth"]["type"].should == 'oauth2'
      json["auth"]["uid"].should  == user.id
    end
  end

  context "with client credential authentication" do
    xit "should can authorize as client with given access token as bearer token" do
      post "/oauth/token?grant_type=client_credentials", {}, auth_basic(client)

      tokens = JSON[response.body]
      access_token = tokens["access_token"]

      get "/api/status", {}, auth_basic(client)

      response.status.should == 200
      json = JSON[response.body]

      json["auth"]["type"].should == 'client'
      json["auth"]["uid"].should  == client.identifier
    end
  end
end
