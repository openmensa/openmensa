# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Canteen', type: :feature do
  let(:canteen)  { FactoryGirl.create :canteen }
  let(:canteens) { [canteen] + (0..25).map { FactoryGirl.create :canteen } }

  describe 'index map' do
    before { canteens }

    it 'have markers with links to all canteens', js: true do
      skip 'TODO'
    end
  end

  describe '#show' do
    it 'should list the canteen\'s telephone number' do
      canteen.update_attribute :phone, '0331 243 580/051'

      visit canteen_path(canteen)

      expect(page).to have_content '0331 243 580/051'
    end

    it 'should list the canteen\'s email address' do
      canteen.update_attribute :email, 'test@example.org'

      visit canteen_path(canteen)

      expect(page).to have_content 'test@example.org'
    end
  end
end
