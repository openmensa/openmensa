# frozen_string_literal: true

require "spec_helper"

describe Identity do
  subject(:identity) { create(:identity) }

  describe "#provider" do
    it "is not valid without a provider" do
      identity.update(provider: nil)
      expect(identity).not_to be_valid
    end

    it "is not valid with an empty provider" do
      identity.update(provider: "")
      expect(identity).not_to be_valid
    end
  end

  describe "#uid" do
    it "is not valid without a uid" do
      identity.update(uid: nil)
      expect(identity).not_to be_valid
    end

    it "is not valid with an empty uid" do
      identity.update(uid: "")
      expect(identity).not_to be_valid
    end
  end
end
