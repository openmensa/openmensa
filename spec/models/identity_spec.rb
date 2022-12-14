# frozen_string_literal: true

require "spec_helper"

describe Identity do
  subject { @identity = create(:identity) }

  describe "attributes" do
    it { is_expected.not_to accept_values_for(:provider, "", nil) }
    it { is_expected.not_to accept_values_for(:uid, "", nil) }
  end
end
