# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'
require_dependency 'message'

describe 'Developers', type: :feature do
  let(:user) { FactoryGirl.create :user }
  let(:developer) { FactoryGirl.create :developer }
  let(:parser) { FactoryGirl.create :parser, user: developer }
  let!(:source) { FactoryGirl.create :source, parser: parser, canteen: canteen }
  let(:feed) { FactoryGirl.create :feed, source: source, name: 'debug' }
  let(:canteen) { FactoryGirl.create :canteen }

  context 'as a developer' do
    before do
      login_as developer
      click_on 'Profil'
    end

    context 'on my profile' do
      it 'should be able to see the status of my parser' do
      end

      it 'should be able to move my source to another parser' do
      end

      it 'should be able to disable/delete a source' do
      end
    end

    context 'on my canteens page' do
      before do
        canteen
        click_on 'Meine Mensen'
      end

      it 'should be able to edit own canteens' do
        click_on 'Mensa bearbeiten'

        new_url = 'http://example.org/canteens.xml'
        new_url_2 = 'http://example.org/canteens-today.xml'
        new_name = 'Test-Mensa'
        new_address = 'Essensweg 34, 12345 Hunger, Deutschland'
        new_city = 'Halle'
        new_phone = '0331 498 304/234'
        new_email = 'test2@new-domain.org'

        fill_in 'Name', with: new_name
        fill_in 'Stadt', with: new_city
        fill_in 'Adresse', with: new_address
        fill_in 'Telefonnummer', with: new_phone
        fill_in 'E-Mail', with: new_email
        click_on 'Speichern'

        canteen.reload

        expect(canteen.name).to eq(new_name)
        expect(canteen.address).to eq(new_address)
        expect(canteen.city).to eq(new_city)
        expect(canteen.phone).to eq(new_phone)
        expect(canteen.email).to eq(new_email)

        expect(page).to have_content 'Mensa gespeichert.'
      end
    end

    context 'on my canteen page' do
      let(:updater) { OpenMensa::Updater.new(feed, 'manual') }

      before do
        feed
        visit canteen_path canteen
      end

      it 'should allow to fetch the canteen feed again' do
        expect(OpenMensa::Updater).to receive(:new).with(feed, 'manual').and_return updater
        expect(updater).to receive(:update).and_return true

        click_on 'Feed debug abrufen'

        expect(page).to have_content 'Der Mensa-Feed wurde erfolgreich aktualisiert!'
        expect(page).to have_content canteen.name
      end

      it 'should allow to disable the canteen' do
        click_on 'Mensa außer Betrieb nehmen'

        expect(page).to have_content 'Die Mensa ist nun außer Betrieb!'
        expect(page).to have_content canteen.name
      end

      context 'with deactivated canteen' do
        let(:canteen) { FactoryGirl.create :canteen, state: 'archived' }

        it 'should allow to disable the canteen' do
          click_on 'Mensa in Betrieb nehmen'

          expect(page).to have_content 'Die Mensa ist nun im Betrieb!'
          expect(page).to have_content canteen.name
        end
      end
    end

    context 'on my messages page' do
      let(:message) { FactoryGirl.create :feedValidationError, messageable: feed, kind: :invalid_xml }
      before do
        message
        click_on 'Statusmitteilungen'
      end

      it 'should allow to view own messages' do
        pending 'needs porting'
        click_on canteen.name
        expect(page).to have_content message.canteen.name
        expect(page).to have_content message.message
      end
    end

    context 'on profile page' do
      it 'should allow to activate (daily) report mails' do
        expect(developer.send_reports?).to be_falsey

        check 'Sende Error-Reports per Mail (maximal täglich)'
        click_on 'Speichern'

        developer.reload

        expect(developer.send_reports?).to be_truthy
      end

      it 'should allow to deactivate (daily) report mails' do
        developer.send_reports = true
        developer.save!

        uncheck 'Sende Error-Reports per Mail (maximal täglich)'
        click_on 'Speichern'

        developer.reload

        expect(developer.send_reports?).to be_falsey
      end

      it 'should not be able to remove email' do
        fill_in 'E-Mail', with: ''
        click_on 'Speichern'

        expect(page).to have_content('muss ausgefüllt werden')
      end
    end
  end

  context 'as a user' do
    before do
      login_as user
      click_on 'Profil'
    end

    it 'should become a developer when he enters an email' do
      fill_in 'E-Mail', with: 'boby@altimos.de'
      click_on 'Speichern'

      user.reload
      expect(user).to be_developer
      expect(page).to have_content('Entwickler')
    end
  end
end
