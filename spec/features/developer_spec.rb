# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'
require_dependency 'message'

describe 'Developers', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:developer) { FactoryBot.create :developer }
  let(:parser) { FactoryBot.create :parser, user: developer }
  let!(:source) { FactoryBot.create :source, parser: parser, canteen: canteen }
  let(:feed) { FactoryBot.create :feed, source: source, name: 'debug' }
  let(:canteen) { FactoryBot.create :canteen }

  context 'as user' do
    before do
      login_as user
      click_on 'Profil'
    end

    it 'I want to inform me about developer features' do
      expect(page).not_to have_content('Entwickler-Einstellungen')
      click_on 'Mehr zu Entwickler-Funktionen'
      expect(page).to have_content('Was bringt es Entwickler zu sein?')
      expect(page).to have_content('Was muss ich tun?')
    end

    it 'I want to become a developer' do
      click_on 'Aktiviere Entwickler-Funktionen'

      fill_in 'E-Mail für Fehlerberichte und ähnliches', with: 'test@example.org'

      click_on 'Werde Entwickler'

      expect(page).to have_content('Eine Bestätigungsmail wurde an test@example.org gesendet. Bitte öffene den darin enthaltenen Link, um die E-Mail-Adresse zu bestätigen.')

      expect(ActionMailer::Base.deliveries).not_to be_empty

      mail = ActionMailer::Base.deliveries.first
      expect(mail.to).to match_array ['test@example.org']
      expect(mail.subject).to eq 'OpenMensa: Bestätige deine Entwickler-Mail-Adresse'

      if mail.body.to_s =~ %r{(https?://[-a-zA-Z0-9=_./]+)}
        visit Regexp.last_match(1)
      end

      expect(user.reload).to be_developer
    end
  end

  context 'as a developer' do
    before do
      login_as developer
      click_on 'Profil'
    end

    it 'is able to edit own canteens' do
      click_on parser.name
      click_on "Editiere #{canteen.name}"

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

    context 'on my canteen page' do
      let(:updater) { OpenMensa::Updater.new(feed, 'manual') }

      before do
        feed
        visit canteen_path canteen
      end

      it 'allows to fetch the canteen feed again' do
        expect(OpenMensa::Updater).to receive(:new).with(feed, 'manual').and_return updater
        expect(updater).to receive(:update).and_return true

        click_on 'Feed debug abrufen'

        expect(page).to have_content 'Der Mensa-Feed wurde erfolgreich aktualisiert!'
        expect(page).to have_content canteen.name
      end

      it 'allows to disable the canteen' do
        click_on 'Mensa außer Betrieb nehmen'

        expect(page).to have_content 'Die Mensa ist nun außer Betrieb!'
        expect(page).to have_content canteen.name
        expect(page).not_to have_link 'Mensa außer Betrieb nehmen'
      end

      context 'with previous fetches and errors' do
        let!(:fetch) { FactoryBot.create :feed_fetch, feed: feed, state: 'broken' }
        let!(:error) { FactoryBot.create :feedValidationError, messageable: fetch }

        it 'is able to view fetch messages / errors' do
          click_on 'Feed debug-Mitteilungen'

          expect(page).to have_content('permanenter Fehler')
          expect(page).to have_content(error.to_html)
        end
      end

      context 'with deactivated canteen' do
        let(:canteen) { FactoryBot.create :canteen, state: 'archived' }

        it 'allows to enable the canteen' do
          click_on 'Mensa in Betrieb nehmen'

          expect(page).to have_content 'Die Mensa ist nun im Betrieb!'
          expect(page).to have_content canteen.name
          expect(page).not_to have_link 'Mensa in Betrieb nehmen'
        end
      end
    end

    context 'on profile page' do
      it 'is able to update notification email' do
        fill_in 'E-Mail für Fehlerberichte', with: 'test+openmensa@example.com'
        click_on 'Speichern'

        expect(developer.reload.notify_email).to eq 'test+openmensa@example.com'
      end

      it 'is able to set public information' do
        expect(developer.public_name).to be_nil
        expect(developer.public_email).to be_nil
        expect(developer.info_url).to be_nil

        fill_in 'Website', with: 'http://example.org'
        fill_in 'Öffentlicher Name', with: 'Hans Otto'
        fill_in 'Öffentliche E-Mail', with: 'openmensa@example.org'
        click_on 'Speichern'

        developer.reload
        expect(developer.public_name).to eq 'Hans Otto'
        expect(developer.public_email).to eq 'openmensa@example.org'
        expect(developer.info_url).to eq 'http://example.org'
      end
    end
  end
end
