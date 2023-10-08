# frozen_string_literal: true

require "spec_helper"

describe User do
  subject(:user) { create(:user) }

  describe "#login" do
    it "is not valid without a login" do
      user = build(:user, login: nil)
      expect(user).not_to be_valid
    end

    it "is not valid with an empty login" do
      user = build(:user, login: "")
      expect(user).not_to be_valid
    end

    it "accepts valid login names" do
      ["first.last", "abc", "heinz_klein"].each do |valid|
        user = build(:user, login: valid)
        expect(user).to be_valid
      end
    end

    it "canno be a reserved name" do
      %w[anonymous system].each do |reserved|
        user = build(:user, login: reserved)
        expect(user).not_to be_valid
      end
    end
  end

  describe "#email" do
    it "can be nil" do
      user = build(:user, email: nil)
      expect(user).to be_valid
    end

    it "can be empty" do
      user = build(:user, email: "")
      expect(user).to be_valid
    end

    it "accepts valid email addresses" do
      ["abc@example.org", "admin@altimos.de"].each do |valid|
        user = build(:user, email: valid)
        expect(user).to be_valid
      end
    end
  end

  describe "#name" do
    it "is not valid without a name" do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end

    it "is not valid with an empty name" do
      user = build(:user, name: "")
      expect(user).not_to be_valid
    end

    it "accepts valid name strings" do
      ["John Smith", "Yung Heng", "K. Müller"].each do |valid|
        user = build(:user, name: valid)
        expect(user).to be_valid
      end
    end
  end

  it { is_expected.to be_logged }
  it { is_expected.not_to be_admin }
  it { is_expected.not_to be_internal }
  it { expect(user.language).to eq I18n.locale.to_s }
  it { expect(user.time_zone).to eq "Berlin" }

  it "setting a email should not get the user a developer" do
    user = create(:user)

    user.email = "bob@example.org"
    expect(user).to be_valid
    user.save

    expect(user.reload).not_to be_developer
  end

  it "requires an public name for a info url" do
    user = create(:user)

    user.info_url = "bob@example.org"
    expect(user).not_to be_valid
    expect(user.save).to be_falsey

    user.public_name = "Bob"

    expect(user).to be_valid
    user.save
  end

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

      let(:anon) { User.anonymous }

      before { anon }

      it("is an AnonymousUser") { is_expected.to be_an AnonymousUser }
      it("has reserved anonymous login") { expect(anon.login).to eq "anonymous" }
      it("alwayses return same instance") { is_expected.to eq User.anonymous }
      it { is_expected.not_to be_logged }
      it { is_expected.not_to be_admin }
      it { is_expected.to be_internal }
    end
  end

  describe "@scopes" do
    describe "#all" do
      it "does not contain AnonymousUser" do
        User.anonymous # enforce that AnonymousUser and
        create(:user)

        expect(User.all).not_to be_empty
        expect(User.all.select {|u| u.login == "anonymous" || u.login == "system" }).to be_empty
      end
    end
  end

  context "@authorization" do
    context "Anonymous" do
      subject { User.anonymous }

      let(:user) { create(:user) }

      it { is_expected.not_to be_able_to(:index, User, "Users") }
      it { is_expected.not_to be_able_to(:new, User, "a User") }
      it { is_expected.not_to be_able_to(:create, User, "a User") }
      it { is_expected.not_to be_able_to(:show, user, "a User") }
      it { is_expected.not_to be_able_to(:edit, user, "a User") }
      it { is_expected.not_to be_able_to(:update, user, "a User") }
      it { is_expected.not_to be_able_to(:delete, user, "a User") }
      it { is_expected.not_to be_able_to(:destroy, user, "a User") }
      it { is_expected.not_to be_able_to(:show, User.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:edit, User.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:update, User.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:delete, User.anonymous, "himself") }
      it { is_expected.not_to be_able_to(:destroy, User.anonymous, "himself") }
    end

    context "User" do
      subject { user }

      let(:user) { create(:user) }
      let(:user2) { create(:user) }

      it { is_expected.not_to be_able_to(:index, User, "Users") }
      it { is_expected.not_to be_able_to(:new, User, "a User") }
      it { is_expected.not_to be_able_to(:create, User, "a User") }
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

      let(:admin) { create(:admin) }
      let(:admin2) { create(:admin) }
      let(:user) { create(:user) }

      it { is_expected.to be_able_to(:create, User, "Users") }
      it { is_expected.to be_able_to(:index, User, "Users") }
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
