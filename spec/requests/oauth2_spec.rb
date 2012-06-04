# encoding: UTF-8
require "spec_helper"

describe "OAuth2" do
  let(:client)    { FactoryGirl.create :client }
  let(:identity)  { FactoryGirl.create :identity }
  let(:user)      { identity.user }
  let(:auth_code) { Oauth2::AuthorizationCode.create! client: client, user: user }

  context "with authorization code authentication" do
    it "should get an access token and a refresh token" do
      post "/oauth/token?" +
        [
          "grant_type=authorization_code",
          "client_id=#{client.identifier}",
          "client_secret=#{client.secret}",
          "code=#{auth_code.token}"
        ].join("&")

      response.status.should == 200

      tokens = JSON[response.body]
      tokens["access_token"].should be_present
      tokens["refresh_token"].should be_present

      access_token  = tokens["access_token"]
      refresh_token = tokens["refresh_token"]
    end

    it "should can authorize as user with given access token as bearer token" do
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

      get "/api/index", {}, { "HTTP_AUTHORIZATION" => "Bearer #{access_token}" }

      response.should be_ok
      json = JSON[response.body]

      json["result"]["auth"]["type"].should == 'oauth2'
      json["result"]["auth"]["uid"].should  == user.id
    end
  end

  context "with client credential authentication" do
    it "should get an acces token and no refresh token" do
      post "/oauth/token?grant_type=client_credentials", {}, basic(client)

      response.status.should == 200

      tokens = JSON[response.body]
      tokens["access_token"].should be_present
      tokens["refresh_token"].should be_nil
    end

    it "should can authorize as client with given access token as bearer token" do
      post "/oauth/token?grant_type=client_credentials", {}, basic(client)

      tokens = JSON[response.body]
      access_token = tokens["access_token"]

      get "/api/index", {}, { "HTTP_AUTHORIZATION" => "Bearer #{access_token}" }

      response.status.should == 200
      json = JSON[response.body]

      json["result"]["auth"]["type"].should == 'client'
      json["result"]["auth"]["uid"].should  == client.identifier
    end
  end
end
