# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"
require_dependency 'message'

describe "canteens/fetch.html.slim" do
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
      view.stub(:current_user) { owner }
    end

    it 'should display updated entities' do
      assign(:result, success_result)

      render

      rendered.should include('Der Mensa-Feed wurde erfolgreich aktualisiert!')

      rendered.should include('101 Tage hinzugefügt')
      rendered.should include('102 Tage aktualisiert')
      rendered.should include('201 Essen hinzugefügt')
      rendered.should include('202 Essen aktualisiert')
      rendered.should include('203 Essen gelöscht')
    end

    it 'should display fetch errors' do
      assign(:result, error_result)

      render

      rendered.should include('Der Mensa-Feed konnte nicht abgerufen werden!')

      rendered.should include('Could not fetch')
    end
  end

  context 'as other user' do
    before do
      assign(:user, other)
      assign(:canteen, canteen)
      view.stub(:current_user) { other }
    end

    it 'should not display updated entities' do
      assign(:result, {'status' => 'ok'})

      render

      rendered.should include('Der Mensa-Feed wurde erfolgreich aktualisiert!')

      rendered.should_not include('101 Tage hinzugefügt')
      rendered.should_not include('102 Tage aktualisiert')
      rendered.should_not include('103 Essen hinzugefügt')
      rendered.should_not include('104 Essen aktualisiert')
      rendered.should_not include('105 Essen gelöscht')
    end

    it 'should display fetch errors' do
      assign(:result, {'status' => 'error'})

      render

      rendered.should include('Der Mensa-Feed konnte nicht abgerufen werden!')

      rendered.should_not include('Could not fetch')
    end
  end
end
