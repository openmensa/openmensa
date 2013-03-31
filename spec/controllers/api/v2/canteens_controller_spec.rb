require 'spec_helper'

describe Api::V2::CanteensController do
  render_views

  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:canteen) { FactoryGirl.create :canteen, latitude: 0.0, longitude: 0.0 }
    before        { canteen }

    it "should answer with a list" do
      get :index, format: :json
      response.status.should == 200

      json.should be_an(Array)
      json.should have(1).item
    end

    it "should answer with a list of canteen nodes" do
      get :index, format: :json
      response.status.should == 200

      json[0].should == {
        :id => canteen.id,
        :name => canteen.name,
        :address => canteen.address,
        :coordinates => [
          canteen.latitude,
          canteen.longitude
        ]
      }.as_json
    end

    it "should add link headers" do
      100.times { FactoryGirl.create :canteen }
      Canteen.count.should > 100

      get :index, format: :json

      response.status.should == 200
      response.headers["Link"].to_s.should include('<http://test.host/api/v2/canteens?page=1>; rel="first"')
      response.headers["Link"].to_s.should include('<http://test.host/api/v2/canteens?page=2>; rel="next"')
      response.headers["Link"].to_s.should include('<http://test.host/api/v2/canteens?page=3>; rel="last"')
    end

    context "&limit" do
      it "should limit list to given limit parameter" do
        100.times { FactoryGirl.create :canteen }
        Canteen.count.should > 100

        get :index, format: :json, limit: "20"

        response.status.should == 200
        json.should have(20).items
      end

      it "should limit list to 100 if given limit parameter exceed 100" do
        100.times { FactoryGirl.create :canteen }
        Canteen.count.should > 100

        get :index, format: :json, limit: "120"

        response.status.should == 200
        json.should have(100).items
      end
    end

    context "&per_page" do
      it "should limit list to 50 canteens by default" do
        100.times { FactoryGirl.create :canteen }
        Canteen.count.should > 100

        get :index, format: :json

        response.status.should == 200
        json.should have(50).items
      end

      it "should limit list to given limit parameter" do
        100.times { FactoryGirl.create :canteen }
        Canteen.count.should > 100

        get :index, format: :json, per_page: "20"

        response.status.should == 200
        json.should have(20).items
      end

      it "should limit list to 100 if given limit parameter exceed 100" do
        100.times { FactoryGirl.create :canteen }
        Canteen.count.should > 100

        get :index, format: :json, per_page: "120"

        response.status.should == 200
        json.should have(100).items
      end
    end

    context "&near" do
      before do
        FactoryGirl.create :canteen, latitude: 0.0, longitude: 0.1
        FactoryGirl.create :canteen, latitude: 0.0, longitude: 0.2
      end

      it "should find canteens within distance around a point" do
        get :index, format: :json, near: { lat: 0.0, lng: 0.15, dist: 100 }

        json.should have(3).items
      end

      it "should find canteens within default distance around a point" do
        get :index, format: :json, near: { lat: 0.05, lng: 0.1 }

        json.should have(1).items
      end
    end

    context "&ids" do
      let(:second_canteen) { FactoryGirl.create :canteen }
      before do
        FactoryGirl.create :canteen
        second_canteen
        FactoryGirl.create :canteen
      end

      it "should return canteens with given ids" do
        get :index, format: :json, ids: [ canteen.id, second_canteen.id ].join(',')

        json.should have(2).items
        json[0]['id'].should == canteen.id
        json[1]['id'].should == second_canteen.id
      end
    end

    context '&near[place]' do
      let(:griebnitzsee) do FactoryGirl.create :canteen,
        name: "Mensa Griebnitzsee",
        address: "August-Bebel-Str. 89, 14482 Potsdam",
        latitude: 52.3935353446923,
        longitude: 13.1278145313263
      end

      let(:palais) do FactoryGirl.create :canteen,
        name: "Mensa Am Neuen Palais",
        address: "Am Neuen Palais 10, Haus 12, 14469 Potsdam",
        latitude: 52.399,
        longitude: 13.01494
      end

      before do
        griebnitzsee
        palais
        stub_request(:get, "http://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&polygon=1&q=Potsdam").
          to_return(lambda { |request| File.new Rails.root.join(*%w{spec mocks nominatim.json}).to_s })
      end

      it 'should return canteens near a specified place' do
        get :index, format: :json, near: { place: 'Potsdam' }

        json.should have(2).item
        json[0]['name'].should == palais.name
        json[1]['name'].should == griebnitzsee.name
      end
    end
  end

  describe "GET show" do
    let(:canteen) { FactoryGirl.create :canteen }
    before        { canteen }

    it "should answer with canteen" do
      get :show, id: canteen.id, format: :json
      response.status.should == 200

      json.should == {
        :id => canteen.id,
        :name => canteen.name,
        :address => canteen.address,
        :coordinates => [
          canteen.latitude,
          canteen.longitude
        ]
      }.as_json
    end
  end
end
