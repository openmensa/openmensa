require 'spec_helper'

describe Identity do
  subject { @identity = FactoryGirl.create(:identity) }

  describe "attributes" do
    it { should_not accept_values_for(:provider, '', nil) }
    it { should_not accept_values_for(:uid, '', nil) }
  end

  describe '@massassignment' do
    context 'when create' do
      subject { Identity.new }

      it do
        should have_safe_attributes(:password, :user_id, :user, :uid, :provider, :token, :secret)
      end

      it do
        should have_safe_attributes(:password, :user_id, :user, :uid, :provider, :token, :secret).
          as(FactoryGirl.create(:user), 'User')
      end

      it do
        should have_safe_attributes(:password, :user_id, :user, :uid, :provider, :token, :secret).
          as(FactoryGirl.create(:admin), 'Administrator').and_as(User.system, 'System')
      end
    end

    context 'when update' do
      before  { @identity = FactoryGirl.create(:identity) }
      subject { @identity }

      it do
        should have_no_safe_attributes
      end

      it do
        should have_no_safe_attributes.as(FactoryGirl.create(:user), '(another) User')
      end

      it do
        should have_no_safe_attributes.as(@identity.user, 'himself')
      end

      it do
        admin = FactoryGirl.create(:admin)
        should have_no_safe_attributes.as(admin, 'Administrator').and_as(User.system, 'System')
      end
    end
  end
end
