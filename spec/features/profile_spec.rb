# encoding: UTF-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'Profile page', type: :feature do
  let(:user) { FactoryGirl.create :user }

  before do
    login_as user
    click_link 'Profil'
  end

  it 'should allow user to change name and email' do
    expect(page).to have_content('Name')
    expect(page).to have_content('E-Mail')

    fill_in 'Name', with: 'Boby Short'
    fill_in 'E-Mail', with: 'boby@altimos.de'
    click_on 'Speichern'

    expect(page).to have_content('Profil gespeichert.')

    expect(find_field('Name').value).to eq('Boby Short')
    expect(find_field('E-Mail').value).to eq('boby@altimos.de')
  end

  it 'should raise error when user tries to update with empty name' do
    expect(page).to have_content('Name')
    expect(page).to have_content('E-Mail')

    fill_in 'Name', with: ''
    fill_in 'E-Mail', with: 'boby@altimos.de'
    click_on 'Speichern'

    expect(page).to have_content('muss ausgefüllt werden')
    expect(find_field('Name').value).to eq('')
    expect(find_field('E-Mail').value).to eq('boby@altimos.de')
  end

  it 'should allow user to add an identity' do
    click_link 'Identität hinzufügen'

    expect { click_link 'GitHub' }.to change { Identity.all.count }.by(1)

    expect(Identity.last.provider).to eq('github')

    expect(current_path).to eq(user_path(user))
    expect(page).to have_content('GitHub Identität hinzugefügt.')
  end

  it 'should allow user to remove an identity' do
    click_link 'Identität hinzufügen'
    click_link 'GitHub'

    expect { click_link 'Twitter Identität entfernen' }.to change {
      Identity.all.count
    }.from(2).to(1)

    expect(Identity.first.provider).to eq('github')

    expect(page).to have_content('Twitter Identität entfernt.')
  end
end
