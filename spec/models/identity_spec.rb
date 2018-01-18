require 'spec_helper'

describe Identity, type: :model do
  subject { @identity = FactoryBot.create(:identity) }

  describe 'attributes' do
    it { is_expected.not_to accept_values_for(:provider, '', nil) }
    it { is_expected.not_to accept_values_for(:uid, '', nil) }
  end
end
