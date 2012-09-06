require 'spec_helper'

describe Meal do
  let(:meal) { FactoryGirl.create :meal }

  it { should_not accept_values_for(:name, "", nil) }
  it { should_not accept_values_for(:category, "", nil) }
  it { should_not accept_values_for(:day_id, "", nil) }

  describe '#prices' do
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

  describe '#notes=' do
    it 'should to clear notes list' do
      meal.notes << FactoryGirl.create(:note)
      meal.notes << FactoryGirl.create(:note)
      meal.notes.size.should == 2
      meal.notes = []
      meal.notes.size.should be_zero
    end

    it 'should add new notes' do
      meal.notes.size.should == 0
      meal.notes = ['vegan', 'vegetarisch']
      meal.notes.size.should == 2
      meal.notes.map(&:name).should == [ 'vegan', 'vegetarisch' ]
    end

    it 'should removed old notes' do
      meal.notes << note = FactoryGirl.create(:note)
      oldname = note.name
      meal.notes.size.should == 1
      meal.notes = [oldname + '2']
      meal.notes.size.should == 1
      meal.notes.first.name.should == oldname + '2'
    end
  end
end
