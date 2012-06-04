require 'spec_helper'

describe Oauth2::AccessToken do
  subject { @token = FactoryGirl.create(:access_token) }

  it { should be_a(Oauth2::Token) }
  it { should_not accept_values_for(:client, nil) }

  it "should generate token and expires_at when save" do
    token = FactoryGirl.build(:access_token)
    token.token.should be_nil
    token.expires_at.should be_nil

    token.save!
    token.token.should_not be_nil
    token.expires_at.should_not be_nil
  end

  describe '@massassignment' do
    context 'when create' do
      subject { Oauth2::AccessToken.new }

      it do
        should have_safe_attributes(:user, :client)
      end

      it do
        should have_safe_attributes(:user, :client).as(FactoryGirl.create(:user), 'User')
      end

      it do
        should have_safe_attributes(:user, :client).
          as(FactoryGirl.create(:admin), 'Administrator').and_as(User.system, 'System')
      end
    end

    context 'when update' do
      subject { @token = FactoryGirl.create(:access_token) }

      it do
        should have_no_safe_attributes
      end

      it do
        should have_no_safe_attributes.as(FactoryGirl.create(:user), 'User')
      end

      it do
        admin = FactoryGirl.create(:admin)
        should have_no_safe_attributes.as(admin, 'Administrator').and_as(User.system, 'System')
      end
    end
  end
end
