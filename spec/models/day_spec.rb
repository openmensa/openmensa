require 'spec_helper'

describe Day do
  let(:day) { FactoryGirl.create :day }

  it { should_not accept_values_for(:date, nil, "") }
  it { should_not accept_values_for(:canteen_id, nil, "") }

  it 'should have unique date per canteen' do
    same_day = FactoryGirl.build :day, canteen: day.canteen, date: day.date
    same_day.should_not be_valid
  end
end
