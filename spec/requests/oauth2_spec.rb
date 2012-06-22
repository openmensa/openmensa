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
  end

  context "with client credential authentication" do
    it "should get an acces token and no refresh token" do
      post "/oauth/token?grant_type=client_credentials", {}, basic(client)

      response.status.should == 200

      tokens = JSON[response.body]
      tokens["access_token"].should be_present
      tokens["refresh_token"].should be_nil
    end
  end
end
