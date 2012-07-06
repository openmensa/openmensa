require 'spec_helper'

describe Cafeteria do
  let(:cafeteria) { FactoryGirl.create :cafeteria }

  it { should_not accept_values_for(:name, nil, "") }
  it { should_not accept_values_for(:address, nil, "") }
  it { should_not accept_values_for(:url, nil, "") }
  it { should_not accept_values_for(:user_id, nil, "") }
end
