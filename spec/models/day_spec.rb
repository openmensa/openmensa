# frozen_string_literal: true

require 'spec_helper'

describe Day, type: :model do
  let(:day) { FactoryBot.create :day }

  it { is_expected.not_to accept_values_for(:date, nil, '') }
  it { is_expected.not_to accept_values_for(:canteen_id, nil, '') }

  it 'should have unique date per canteen' do
    same_day = FactoryBot.build :day, canteen: day.canteen, date: day.date
    expect(same_day).to_not be_valid
  end
end
