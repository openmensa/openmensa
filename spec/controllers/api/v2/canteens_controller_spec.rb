require 'spec_helper'

describe Api::V2::CanteensController, type: :controller do
  render_views

  let(:json) { JSON.parse response.body }

  describe 'GET index' do
    let(:canteen) { FactoryGirl.create :canteen, latitude: 0.0, longitude: 0.0 }
    before        { canteen }

    it 'should answer with a list' do
      get :index, format: :json
      expect(response.status).to eq(200)

      expect(json).to be_an(Array)
      expect(json.size).to eq(1)
    end

    it 'should answer with a list of canteen nodes' do
      get :index, format: :json
      expect(response.status).to eq(200)

      expect(json[0]).to eq({
        id:          canteen.id,
        name:        canteen.name,
        city:        canteen.city,
        address:     canteen.address,
        coordinates: [
          canteen.latitude,
          canteen.longitude
        ]
      }.as_json)
    end

    context 'with null latitude' do
      let(:canteen) { FactoryGirl.create :canteen, latitude: nil, longitude: 0.0 }

      it 'should answer with null coordinates' do
        get :index, format: :json
        expect(response.status).to eq(200)

        expect(json[0]).to eq({
          id:          canteen.id,
          name:        canteen.name,
          city:        canteen.city,
          address:     canteen.address,
          coordinates: nil
        }.as_json)
      end
    end

    context 'with null longitude' do
      let(:canteen) { FactoryGirl.create :canteen, latitude: 0.0, longitude: nil }

      it 'should answer with null coordinates' do
        get :index, format: :json
        expect(response.status).to eq(200)

        expect(json[0]).to eq({
          id:          canteen.id,
          name:        canteen.name,
          city:        canteen.city,
          address:     canteen.address,
          coordinates: nil
        }.as_json)
      end
    end

    context 'with both null coordinates' do
      let(:canteen) { FactoryGirl.create :canteen, latitude: nil, longitude: nil }

      it 'should answer with null coordinates' do
        get :index, format: :json
        expect(response.status).to eq(200)

        expect(json[0]).to eq({
          id:          canteen.id,
          name:        canteen.name,
          city:        canteen.city,
          address:     canteen.address,
          coordinates: nil
        }.as_json)
      end
    end

    it 'should add link headers' do
      100.times { FactoryGirl.create :canteen }
      expect(Canteen.count).to be > 100

      get :index, format: :json

      expect(response.status).to eq(200)
      expect(response.headers['Link'].to_s).to include('<http://test.host/api/v2/canteens?page=1>; rel="first"')
      expect(response.headers['Link'].to_s).to include('<http://test.host/api/v2/canteens?page=2>; rel="next"')
      expect(response.headers['Link'].to_s).to include('<http://test.host/api/v2/canteens?page=3>; rel="last"')
    end

    context 'should not included wanted canteens' do
      let!(:hidden_canteen) { FactoryGirl.create :canteen, state: 'wanted' }
      before { get :index, format: :json }
      subject { json }

      it { is_expected.to be_an(Array) }
      it { is_expected.to have(1).item }
    end

    context 'should not included disabled canteens' do
      let!(:hidden_canteen) { FactoryGirl.create :canteen, state: 'archived' }
      before { get :index, format: :json }
      subject { json }

      it { is_expected.to be_an(Array) }
      it { is_expected.to have(1).item }
    end

    context '&limit' do
      it 'should limit list to given limit parameter' do
        100.times { FactoryGirl.create :canteen }
        expect(Canteen.count).to be > 100

        get :index, format: :json, params: {limit: '20'}

        expect(response.status).to eq(200)
        expect(json.size).to eq(20)
      end

      it 'should limit list to 100 if given limit parameter exceed 100' do
        100.times { FactoryGirl.create :canteen }
        expect(Canteen.count).to be > 100

        get :index, format: :json, params: {limit: '120'}

        expect(response.status).to eq(200)
        expect(json.size).to eq(100)
      end
    end

    context '&per_page' do
      it 'should limit list to 50 canteens by default' do
        100.times { FactoryGirl.create :canteen }
        expect(Canteen.count).to be > 100

        get :index, format: :json

        expect(response.status).to eq(200)
        expect(json.size).to eq(50)
      end

      it 'should limit list to given limit parameter' do
        100.times { FactoryGirl.create :canteen }
        expect(Canteen.count).to be > 100

        get :index, format: :json, params: {per_page: '20'}

        expect(response.status).to eq(200)
        expect(json.size).to eq(20)
      end

      it 'should limit list to 100 if given limit parameter exceed 100' do
        100.times { FactoryGirl.create :canteen }
        expect(Canteen.count).to be > 100

        get :index, format: :json, params: {per_page: '120'}

        expect(response.status).to eq(200)
        expect(json.size).to eq(100)
      end
    end

    context '&near' do
      before do
        FactoryGirl.create :canteen, latitude: 0.0, longitude: 0.1
        FactoryGirl.create :canteen, latitude: 0.0, longitude: 0.2
      end

      it 'should find canteens within distance around a point' do
        get :index, format: :json,
          params: {near: {lat: 0.0, lng: 0.15, dist: 100}}

        expect(json).to have(3).items
      end

      it 'should find canteens within default distance around a point' do
        get :index, format: :json, params: {near: {lat: 0.05, lng: 0.1}}

        expect(json).to have(1).items
      end
    end

    context '&ids' do
      let(:second_canteen) { FactoryGirl.create :canteen }
      before do
        FactoryGirl.create :canteen
        second_canteen
        FactoryGirl.create :canteen
      end

      it 'should return canteens with given ids' do
        get :index, format: :json,
          params: {ids: [canteen.id, second_canteen.id].join(',')}

        expect(json).to have(2).items
        expect(json[0]['id']).to eq(canteen.id)
        expect(json[1]['id']).to eq(second_canteen.id)
      end
    end

    context '&near[place]' do
      let(:griebnitzsee) do
        FactoryGirl.create :canteen,
          name: 'Mensa Griebnitzsee',
          address: 'August-Bebel-Str. 89, 14482 Potsdam',
          latitude: 52.3935353446923,
          longitude: 13.1278145313263
      end

      let(:palais) do
        FactoryGirl.create :canteen,
          name: 'Mensa Am Neuen Palais',
          address: 'Am Neuen Palais 10, Haus 12, 14469 Potsdam',
          latitude: 52.399,
          longitude: 13.01494
      end

      before do
        griebnitzsee
        palais
        stub_request(:get, 'http://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=Potsdam')
          .to_return(->(_request) { File.new Rails.root.join(*%w(spec mocks nominatim.json)).to_s })
      end

      it 'should return canteens near a specified place' do
        get :index, format: :json, params: {near: {place: 'Potsdam'}}

        expect(json).to have(2).item
        expect(json[0]['name']).to eq(palais.name)
        expect(json[1]['name']).to eq(griebnitzsee.name)
      end
    end

    context '&hasCoordinates' do
      let(:griebnitzsee) do
        FactoryGirl.create :canteen,
          name: 'Mensa Griebnitzsee',
          address: 'August-Bebel-Str. 89, 14482 Potsdam',
          latitude: 52.3935353446923,
          longitude: 13.1278145313263
      end

      let(:unknown) do
        FactoryGirl.create :canteen,
          name: 'Mensa Am Neuen Palais',
          address: 'Am Neuen Palais 10, Haus 12, 14469 Potsdam',
          latitude: nil,
          longitude: nil
      end

      before do
        griebnitzsee
        unknown
      end

      it 'should return only canteens when hasCoordinates is true' do
        get :index, format: :json, params: {hasCoordinates: 'true'}

        expect(json).to have(2).item
        expect(json[0]['name']).to eq(canteen.name)
        expect(json[1]['name']).to eq(griebnitzsee.name)
      end

      it 'should return only canteens when hasCoordinates is false' do
        get :index, format: :json, params: {hasCoordinates: 'false'}

        expect(json).to have(1).item
        expect(json[0]['name']).to eq(unknown.name)
      end
    end
  end

  describe 'GET show' do
    let!(:canteen) { FactoryGirl.create :canteen }
    before { get :show, format: :json, params: {id: canteen.id} }

    it 'should answer with canteen' do
      get :show, format: :json, params: {id: canteen.id}
      expect(response.status).to eq(200)

      expect(json).to eq({
        id:          canteen.id,
        name:        canteen.name,
        city:        canteen.city,
        address:     canteen.address,
        coordinates: [
          canteen.latitude,
          canteen.longitude
        ]
      }.as_json)
    end

    context 'and a wanted canteens' do
      let(:canteen) { FactoryGirl.create :canteen, state: 'wanted' }
      subject { json }

      context 'response' do
        subject { response }
        its(:status) { should == 200 }
      end

      context 'json' do
        subject { json }
        its(['id']) { should be canteen.id }
      end
    end

    context 'and a archived canteens' do
      let(:canteen) { FactoryGirl.create :canteen, state: 'archived' }
      subject { json }

      context 'response' do
        subject { response }
        its(:status) { should == 200 }
      end

      context 'json' do
        subject { json }
        its(['id']) { should be canteen.id }
      end
    end

    context 'and a replaced canteens' do
      let(:replacement) { FactoryGirl.create :canteen, state: 'active'}
      let(:canteen) { FactoryGirl.create :canteen, state: 'archived', replaced_by: replacement }
      subject { json }

      context 'response' do
        subject { response }
        its(:status) { should == 200 }
      end

      context 'json' do
        subject { json }
        its(['id']) { should be replacement.id }
      end
    end
  end
end
