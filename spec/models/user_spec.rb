# encoding: UTF-8
require 'spec_helper'

describe User, type: :model do
  let(:user) { FactoryBot.create :user }
  before { user }
  subject { user }

  it { is_expected.to accept_values_for(:login, 'first.last', 'abc', 'heinz_klein') }
  it { is_expected.not_to accept_values_for(:login, '', nil) }
  it { is_expected.to accept_values_for(:email, nil, '', 'abc@example.org', 'admin@altimos.de') }
  it { is_expected.not_to accept_values_for(:email, 'abc', '@domain', 'user@', 'root@local') }
  it { is_expected.to accept_values_for(:name, 'John Smith', 'Yung Heng', 'K. Müller') }
  it { is_expected.not_to accept_values_for(:name, nil, '') }
  it { is_expected.to be_logged }
  it { is_expected.not_to be_admin }
  it { is_expected.not_to be_internal }
  it { expect(user.language).to eq I18n.locale.to_s }
  it { expect(user.time_zone).to eq 'Berlin' }

  it 'setting a email should not get the user a developer' do
    user = FactoryBot.create :user

    user.email = 'bob@example.org'
    expect(user).to be_valid
    user.save

    expect(user.reload).to_not be_developer
  end

  it 'should require an public name for a info url' do
    user = FactoryBot.create :user

    user.info_url = 'bob@example.org'
    expect(user).to_not be_valid
    expect(user.save).to be_falsey

    user.public_name = 'Bob'

    expect(user).to be_valid
    user.save
  end

  # reserved logins
  it { is_expected.not_to accept_values_for(:login, 'anonymous', 'system') }

  it 'should have a unique login' do
    another_user = FactoryBot.build(:user, login: user.login)
    expect(another_user.login).to eq user.login
    expect(another_user).to_not be_valid
    expect(another_user.save).to be_falsey
  end

  it 'can be destroyed' do
    user = FactoryBot.create(:user)
    expect(user.destroy).to be_truthy
  end

  context 'when admin' do
    let(:admin) { FactoryBot.create(:admin) }
    before { admin }
    subject { admin }

    it { is_expected.not_to be_destructible }
    it('can not be destroyed') { expect(admin.destroy).to be_falsey }
  end

  describe '@class' do
    context '#anonymous' do
      let(:anon) { User.anonymous }
      before  { anon }
      subject { anon }

      it('should be an AnonymousUser') { is_expected.to be_an AnonymousUser }
      it('should have reserved anonymous login') { expect(anon.login).to eq 'anonymous' }
      it('should always return same instance') { is_expected.to eq User.anonymous }
      it { is_expected.not_to be_logged }
      it { is_expected.not_to be_admin }
      it { is_expected.to be_internal }
    end
  end

  describe '@scopes' do
    context '#all' do
      it 'does not contain AnonymousUser' do
        User.anonymous # enforce that AnonymousUser and
        FactoryBot.create(:user)

        expect(User.all).to_not be_empty
        expect(User.all.select {|u| u.login == 'anonymous' || u.login == 'system' }).to be_empty
      end
    end
  end

  context '@authorization' do
    context 'Anonymous' do
      subject { User.anonymous }
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.not_to be_able_to(:index, User, 'Users') }
      it { is_expected.not_to be_able_to(:new, User, 'a User') }
      it { is_expected.not_to be_able_to(:create, User, 'a User') }
      it { is_expected.not_to be_able_to(:show, user, 'a User') }
      it { is_expected.not_to be_able_to(:edit, user, 'a User') }
      it { is_expected.not_to be_able_to(:update, user, 'a User') }
      it { is_expected.not_to be_able_to(:delete, user, 'a User') }
      it { is_expected.not_to be_able_to(:destroy, user, 'a User') }
      it { is_expected.not_to be_able_to(:show, User.anonymous, 'himself') }
      it { is_expected.not_to be_able_to(:edit, User.anonymous, 'himself') }
      it { is_expected.not_to be_able_to(:update, User.anonymous, 'himself') }
      it { is_expected.not_to be_able_to(:delete, User.anonymous, 'himself') }
      it { is_expected.not_to be_able_to(:destroy, User.anonymous, 'himself') }
    end
    context 'User' do
      let(:user) { FactoryBot.create :user }
      let(:user2) { FactoryBot.create :user }
      subject { user }

      it { is_expected.not_to be_able_to(:index, User, 'Users') }
      it { is_expected.not_to be_able_to(:new, User, 'a User') }
      it { is_expected.not_to be_able_to(:create, User, 'a User') }
      it { is_expected.not_to be_able_to(:show, user2, 'a User') }
      it { is_expected.not_to be_able_to(:edit, user2, 'a User') }
      it { is_expected.not_to be_able_to(:update, user2, 'a User') }
      it { is_expected.not_to be_able_to(:delete, user2, 'a User') }
      it { is_expected.not_to be_able_to(:destroy, user2, 'a User') }
      it { is_expected.to be_able_to(:show, user, 'himself') }
      it { is_expected.to be_able_to(:edit, user, 'himself') }
      it { is_expected.to be_able_to(:update, user, 'himself') }
      it { is_expected.not_to be_able_to(:delete, user, 'himself') }
      it { is_expected.not_to be_able_to(:destroy, user, 'himself') }
    end
    context 'Administrator' do
      let(:admin) { FactoryBot.create :admin }
      let(:admin2) { FactoryBot.create :admin }
      let(:user) { FactoryBot.create :user }
      subject { admin }

      it { is_expected.to be_able_to(:create, User, 'Users') }
      it { is_expected.to be_able_to(:index, User, 'Users') }
      it { is_expected.to be_able_to(:update, user, 'a User') }
      it { is_expected.to be_able_to(:show, user, 'a User') }
      it { is_expected.to be_able_to(:destroy, user, 'a User') }
      it { is_expected.to be_able_to(:update, admin, 'himself') }
      it { is_expected.to be_able_to(:show, admin, 'himself') }
      it { is_expected.to be_able_to(:update, admin2, 'another Admin') }
      it { is_expected.to be_able_to(:show, admin2, 'another Admin') }
      it { is_expected.not_to be_able_to(:destroy, admin, 'himself') }
      it { is_expected.not_to be_able_to(:destroy, admin2, 'another Admin') }
    end
  end

  describe 'identities' do
    subject { user.identities }

    it { is_expected.not_to be_empty }
  end
end
