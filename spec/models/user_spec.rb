# encoding: UTF-8
require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create :user }
  before { user }
  subject { user }

  it { should accept_values_for(:login, 'first.last', 'abc', 'heinz_klein') }
  it { should_not accept_values_for(:login, '', nil) }
  it { should accept_values_for(:email, nil, '', 'abc@example.org', 'admin@altimos.de') }
  it { should_not accept_values_for(:email, 'abc', '@domain', 'user@', 'root@local') }
  it { should accept_values_for(:name, 'John Smith', 'Yung Heng', 'K. Müller')}
  it { should_not accept_values_for(:name, nil, '') }
  it { should be_logged }
  it { should_not be_admin }
  it { should_not be_internal }
  it { user.language.should == I18n.locale.to_s }
  it { user.time_zone.should == 'Berlin' }

  it 'should require an email if one was set before' do
    user = FactoryGirl.create :user, email: ''

    user.email = 'bob@example.org'
    user.should be_valid
    user.save

    user.email = ''
    user.should_not be_valid
    user.save.should be_false
  end

  # reserved logins
  it { should_not accept_values_for(:login, 'anonymous', 'system')}

  it 'should have a unique login' do
    another_user = FactoryGirl.build(:user, :login => user.login)
    another_user.login.should == user.login
    another_user.should_not be_valid
    another_user.save.should be_false
  end

  it 'can be destroyed' do
    user = FactoryGirl.create(:user)
    user.destroy.should_not be_false
  end

  context 'when admin' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { admin }
    subject { admin }

    it { should_not be_destructible }
    it('can not be destroyed') { admin.destroy.should be_false }
  end

  describe '@class' do
    context '#anonymous' do
      let(:anon) { User.anonymous }
      before  { anon }
      subject { anon }

      it('should be an AnonymousUser') { should be_an AnonymousUser }
      it('should have reserved anonymous login') { anon.login.should == 'anonymous' }
      it('should always return same instance') { should == User.anonymous }
      it { should_not be_logged }
      it { should_not be_admin }
      it { should be_internal }
    end

    context '#current' do
      it 'returns Anonymous by default' do
        User.current = nil
        User.current.should be_an AnonymousUser
      end

      it 'stores a single user object' do
        user = FactoryGirl.create(:user)
        User.current = user

        User.current.should equal(user)
      end
    end
  end

  describe '@scopes' do
    context '#all' do
      it 'does not contain AnonymousUser' do
        User.anonymous # enforce that AnonymousUser and
        FactoryGirl.create(:user)

        User.all.should_not be_empty
        User.all.select { |u| u.login == 'anonymous' or u.login == 'system' }.should be_empty
      end
    end
  end

  context '@authorization' do
    context 'Anonymous' do
      subject { User.anonymous }
      let(:user) { FactoryGirl.create(:user) }

      it { should_not be_able_to(:index, User, 'Users') }
      it { should_not be_able_to(:new, User, 'a User') }
      it { should_not be_able_to(:create, User, 'a User') }
      it { should_not be_able_to(:show, user, 'a User') }
      it { should_not be_able_to(:edit, user, 'a User') }
      it { should_not be_able_to(:update, user, 'a User') }
      it { should_not be_able_to(:delete, user, 'a User') }
      it { should_not be_able_to(:destroy, user, 'a User') }
      it { should_not be_able_to(:show, User.anonymous, 'himself') }
      it { should_not be_able_to(:edit, User.anonymous, 'himself') }
      it { should_not be_able_to(:update, User.anonymous, 'himself') }
      it { should_not be_able_to(:delete, User.anonymous, 'himself') }
      it { should_not be_able_to(:destroy, User.anonymous, 'himself') }
    end
    context 'User' do
      let(:user) { FactoryGirl.create :user }
      let(:user2) { FactoryGirl.create :user }
      subject { user }

      it { should_not be_able_to(:index, User, 'Users') }
      it { should_not be_able_to(:new, User, 'a User') }
      it { should_not be_able_to(:create, User, 'a User') }
      it { should_not be_able_to(:show, user2, 'a User') }
      it { should_not be_able_to(:edit, user2, 'a User') }
      it { should_not be_able_to(:update, user2, 'a User') }
      it { should_not be_able_to(:delete, user2, 'a User') }
      it { should_not be_able_to(:destroy, user2, 'a User') }
      it { should be_able_to(:show, user, 'himself') }
      it { should be_able_to(:edit, user, 'himself') }
      it { should be_able_to(:update, user, 'himself') }
      it { should_not be_able_to(:delete, user, 'himself') }
      it { should_not be_able_to(:destroy, user, 'himself') }
    end
    context 'Administrator' do
      let(:admin) { FactoryGirl.create :admin }
      let(:admin2) { FactoryGirl.create :admin }
      let(:user) { FactoryGirl.create :user }
      subject { admin }

      it { should be_able_to(:create, User, 'Users') }
      it { should be_able_to(:index, User, 'Users') }
      it { should be_able_to(:update, user, 'a User') }
      it { should be_able_to(:show, user, 'a User') }
      it { should be_able_to(:destroy, user, 'a User') }
      it { should be_able_to(:update, admin, 'himself') }
      it { should be_able_to(:show, admin, 'himself') }
      it { should be_able_to(:update, admin2, 'another Admin') }
      it { should be_able_to(:show, admin2, 'another Admin') }
      it { should_not be_able_to(:destroy, admin, 'himself') }
      it { should_not be_able_to(:destroy, admin2, 'another Admin') }
    end
  end

  describe "identities" do
    subject { user.identities }

    it { should_not be_empty }
  end
end
