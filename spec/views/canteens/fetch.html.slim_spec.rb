# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require_dependency 'message'

describe "canteens/fetch.html.slim", :type => :view do
  let(:owner) { FactoryGirl.create :user }
  let(:other) { FactoryGirl.create :user }
  let(:canteen) { FactoryGirl.create(:canteen, user: owner) }
  let(:success_result) do
    {
      'status' => 'ok',
      'days' => {
        'added' => 101,
        'updated' => 102,
      },
      'meals' => {
        'added' => 201,
        'updated' => 202,
        'removed' => 203
      }
    }
  end
  let(:error_result) do
    {
      'status' => 'error',
      'errors' => [
        FeedFetchError.create(canteen: canteen,
                              message: 'Could not fetch',
                              code: 404)
      ]
    }
  end

  context 'as canteen owner' do
    before do
      assign(:user, owner)
      assign(:canteen, canteen)
      allow(view).to receive(:current_user) { owner }
    end

    it 'should display updated entities' do
      assign(:result, success_result)

      render

      expect(rendered).to include('Der Mensa-Feed wurde erfolgreich aktualisiert!')

      expect(rendered).to include('101 Tage hinzugefügt')
      expect(rendered).to include('102 Tage aktualisiert')
      expect(rendered).to include('201 Essen hinzugefügt')
      expect(rendered).to include('202 Essen aktualisiert')
      expect(rendered).to include('203 Essen gelöscht')
    end

    it 'should display fetch errors' do
      assign(:result, error_result)

      render

      expect(rendered).to include('Der Mensa-Feed konnte nicht abgerufen werden!')

      expect(rendered).to include('Could not fetch')
    end
  end

  context 'as other user' do
    before do
      assign(:user, other)
      assign(:canteen, canteen)
      allow(view).to receive(:current_user) { other }
    end

    it 'should not display updated entities' do
      assign(:result, {'status' => 'ok'})

      render

      expect(rendered).to include('Der Mensa-Feed wurde erfolgreich aktualisiert!')

      expect(rendered).not_to include('101 Tage hinzugefügt')
      expect(rendered).not_to include('102 Tage aktualisiert')
      expect(rendered).not_to include('103 Essen hinzugefügt')
      expect(rendered).not_to include('104 Essen aktualisiert')
      expect(rendered).not_to include('105 Essen gelöscht')
    end

    it 'should display fetch errors' do
      assign(:result, {'status' => 'error'})

      render

      expect(rendered).to include('Der Mensa-Feed konnte nicht abgerufen werden!')

      expect(rendered).not_to include('Could not fetch')
    end
  end
end
