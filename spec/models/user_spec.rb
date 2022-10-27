# frozen_string_literal: true

require "spec_helper"

describe User, type: :model do
  subject(:user) { create :user }

  it { is_expected.to accept_values_for(:login, "first.last", "abc", "heinz_klein") }
  it { is_expected.not_to accept_values_for(:login, "", nil) }
  it { is_expected.to accept_values_for(:email, nil, "", "abc@example.org", "admin@altimos.de") }
  it { is_expected.not_to accept_values_for(:email, "abc", "@domain", "user@", "root@local") }
  it { is_expected.to accept_values_for(:name, "John Smith", "Yung Heng", "K. Müller") }
  it { is_expected.not_to accept_values_for(:name, nil, "") }
  it { is_expected.to be_logged }
  it { is_expected.not_to be_admin }
  it { is_expected.not_to be_internal }
  it { expect(user.language).to eq I18n.locale.to_s }
  it { expect(user.time_zone).to eq "Berlin" }

  it "setting a email should not get the user a developer" do
    user = create :user

    user.email = "bob@example.org"
    expect(user).to be_valid
    user.save

    expect(user.reload).not_to be_developer
  end

  it "requires an public name for a info url" do
    user = create :user

    user.info_url = "bob@example.org"
    expect(user).not_to be_valid
    expect(user.save).to be_falsey

    user.public_name = "Bob"

    expect(user).to be_valid
    user.save
  end

  # reserved logins
  it { is_expected.not_to accept_values_for(:login, "anonymous", "system") }

  it "has a unique login" do
    another_user = build(:user, login: user.login)
    expect(another_user.login).to eq user.login
    expect(another_user).not_to be_valid
    expect(another_user.save).to be_falsey
  end

  it "can be destroyed" do
    user = create(:user)
    expect(user.destroy).to be_truthy
  end

  context "when admin" do
    subject { admin }

    let(:admin) { create(:admin) }

    before { admin }

    it { is_expected.not_to be_destructible }
    it("can not be destroyed") { expect(admin.destroy).to be_falsey }
  end

  describe "@class" do
    describe "#anonymous" do
      subject { anon }

      let(:anon) { described_class.anonymous }

      before { anon }

      it("is an AnonymousUser") { is_expected.to be_an AnonymousUser }
      it("has reserved anonymous login") { expect(anon.login).to eq "anonymous" }
      it("alwayses return same instance") { is_expected.to eq described_class.anonymous }
      it { is_expected.not_to be_logged }
      it { is_expected.not_to be_admin }
      it { is_expected.to be_internal }
    end
  end

  describe "@scopes" do
    describe "#all" do
      it "does not contain AnonymousUser" do
        described_class.anonymous # enforce that AnonymousUser and
        create(:user)

        expect(described_class.all).not_to be_empty
        expect(described_class.all.select {|u| u.login == "anonymous" || u.login == "system" }).to be_empty
      end
    end
  end

  context "@authorization" do
    context "Anonymous" do
      subject { described_class.anonymous }

      let(:user) { create(:user) }

      it { is_expected.not_to be_able_to(:index, described_class, "Users") }
      it { is_expected.not_to be_able_to(:new, described_class, "a User") }
      it { is_expected.not_to be_able_to(:create, described_class, "a User") }
      it { is_expected.not_to be_able_to(:show, user, "a User") }
      it { is_expected.not_to be_able_to(:edit, user, "a User") }
      it { is_expected.not_to be_able_to(:update, user, "a User") }
      it { is_expected.not_to be_able_to(:delete, user, "a User") }
      it { is_expected.not_to be_able_to(:destroy, user, "a User") }
      it { is_expected.not_to be_able_to(:show, described_class.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:edit, described_class.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:update, described_class.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:delete, described_class.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:destroy, described_class.anonymous, "himself") }
    end

    context "User" do
      subject { user }

      let(:user) { create :user }
      let(:user2) { create :user }

      it { is_expected.not_to be_able_to(:index, described_class, "Users") }
      it { is_expected.not_to be_able_to(:new, described_class, "a User") }
      it { is_expected.not_to be_able_to(:create, described_class, "a User") }
      it { is_expected.not_to be_able_to(:show, user2, "a User") }
      it { is_expected.not_to be_able_to(:edit, user2, "a User") }
      it { is_expected.not_to be_able_to(:update, user2, "a User") }
      it { is_expected.not_to be_able_to(:delete, user2, "a User") }
      it { is_expected.not_to be_able_to(:destroy, user2, "a User") }
      it { is_expected.to be_able_to(:show, user, "himself") }
      it { is_expected.to be_able_to(:edit, user, "himself") }
      it { is_expected.to be_able_to(:update, user, "himself") }
      it { is_expected.not_to be_able_to(:delete, user, "himself") }
      it { is_expected.not_to be_able_to(:destroy, user, "himself") }
    end

    context "Administrator" do
      subject { admin }

      let(:admin) { create :admin }
      let(:admin2) { create :admin }
      let(:user) { create :user }

      it { is_expected.to be_able_to(:create, described_class, "Users") }
      it { is_expected.to be_able_to(:index, described_class, "Users") }
      it { is_expected.to be_able_to(:update, user, "a User") }
      it { is_expected.to be_able_to(:show, user, "a User") }
      it { is_expected.to be_able_to(:destroy, user, "a User") }
      it { is_expected.to be_able_to(:update, admin, "himself") }
      it { is_expected.to be_able_to(:show, admin, "himself") }
      it { is_expected.to be_able_to(:update, admin2, "another Admin") }
      it { is_expected.to be_able_to(:show, admin2, "another Admin") }
      it { is_expected.not_to be_able_to(:destroy, admin, "himself") }
      it { is_expected.not_to be_able_to(:destroy, admin2, "another Admin") }
    end
  end

  describe "identities" do
    subject { user.identities }

    it { is_expected.not_to be_empty }
  end
end
