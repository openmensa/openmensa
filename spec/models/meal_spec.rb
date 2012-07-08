require 'spec_helper'

describe Meal do
  let(:meal) { Factory.create :meal }

  it { should_not accept_values_for(:name, "", nil) }
  it { should_not accept_values_for(:date, "", nil) }
  it { should_not accept_values_for(:description, "", nil) }
  it { should_not accept_values_for(:cafeteria_id, "", nil) }
end
