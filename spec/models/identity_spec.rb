require 'spec_helper'

describe Identity do
  subject { @identity = FactoryGirl.create(:identity) }

  describe "attributes" do
    it { should_not accept_values_for(:provider, '', nil) }
    it { should_not accept_values_for(:uid, '', nil) }
  end
end
