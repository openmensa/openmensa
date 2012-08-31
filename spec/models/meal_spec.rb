require 'spec_helper'

describe Meal do
  let(:meal) { FactoryGirl.create :meal }

  it { should_not accept_values_for(:name, "", nil) }
  it { should_not accept_values_for(:category, "", nil) }
  it { should_not accept_values_for(:day_id, "", nil) }

  describe '#prices' do
    it 'should be empty by default but not nil' do
      meal.prices.should be_empty
      meal.prices.should_not be_nil
    end

    it 'should only contain setted values' do
      meal.update_attributes({
        price_student: 1.7,
        price_employee: nil,
        price_other: 2.7,
        price_pupil: nil
      })
      meal.prices.should == { student: 1.7, other: 2.7 }
    end

    it 'should could contain all values' do
      meal.update_attributes({
        price_student: 1.7,
        price_employee: 3.37,
        price_other: 2.7,
        price_pupil: 1.89
      })
      meal.prices.should == { student: 1.7, other: 2.7, employee: 3.37, pupil: 1.89 }
    end
  end

  describe '#prices=' do
    it 'should ignore empty hashes' do
      meal.prices = {}
      meal.should_not be_changed
    end

    it 'should update given roles' do
      meal.update_attributes({
        price_student: 1.7,
        price_employee: nil,
        price_other: 2.7,
        price_pupil: nil
      })
      meal.prices = { employee: 1.89, other: nil }
      meal.price_student.should == 1.7
      meal.price_employee.should == 1.89
      meal.price_pupil.should == nil
      meal.price_other.should == nil
      meal.should be_changed
    end
  end
end
