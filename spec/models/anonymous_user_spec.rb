# frozen_string_literal: true

require "spec_helper"

describe AnonymousUser do
  subject(:user) { User.anonymous }

  it { is_expected.not_to be_admin }
  it { is_expected.not_to be_logged }
  it { is_expected.to be_internal }

  it "must be unique" do
    expect(AnonymousUser.new(login: "anonymous")).to be_invalid
  end

  describe "#destroy" do
    it "is indestructable" do
      expect(user.destroy).to be false
    end
  end

  describe "#destroy!" do
    it "is indestructable" do
      expect { user.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
    end
  end
end
