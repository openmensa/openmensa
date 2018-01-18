# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Canteen', type: :feature do
  let(:canteen)  { FactoryBot.create :canteen }
  let(:canteens) { [canteen] + (0..25).map { FactoryBot.create :canteen } }

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

    context 'parser info' do
      let(:owner) { FactoryBot.create :developer }
      let(:parser) { FactoryBot.create :parser, user: owner }
      let!(:source) { FactoryBot.create :source, parser: parser, canteen: canteen}

      it 'should per default not contain any parser info' do
        visit canteen_path(canteen)
        expect(page).to_not have_content('Über Parser')
      end

      it 'should contain user name if wanted' do
        owner.update_attributes public_name: 'Hans Otto'
        visit canteen_path(canteen)

        expect(page).to have_content 'Der Parser wird von Hans Otto bereitgestellt.'
      end

      it 'should contain a user info page if wanted' do
        info_url = 'https://github.com/hansotto'
        owner.update_attributes public_name: 'Hans Otto', info_url: info_url
        visit canteen_path(canteen)

        expect(page).to have_link_to(info_url)
      end

      it 'should contain the user public email if wanted' do
        public_email = 'test@example.com'
        owner.update_attributes public_email: public_email
        visit canteen_path(canteen)

        expect(page).to have_content(public_email)
        expect(page).to have_link_to("mailto:#{public_email}")
      end

      it 'should contain link to parser page if provided' do
        info_url = 'https://github.com/hansotto/om-parser'
        parser.update_attributes info_url: info_url
        visit canteen_path(canteen)

        expect(page).to have_link_to(info_url)
        expect(page).to have_content(info_url)
      end
    end
  end
end
