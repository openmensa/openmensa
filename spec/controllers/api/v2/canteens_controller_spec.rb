# frozen_string_literal: true

require "spec_helper"

describe Api::V2::CanteensController, type: :controller do
  render_views

  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let!(:canteen) { create :canteen, latitude: 0.0, longitude: 0.0 }

    it "answers with a list" do
      get :index, format: :json
      expect(response.status).to eq(200)

      expect(json).to be_an(Array)
      expect(json.size).to eq(1)
    end

    it "answers with a list of canteen nodes" do
      get :index, format: :json
      expect(response.status).to eq(200)

      expect(json[0]).to eq({
        id: canteen.id,
        name: canteen.name,
        city: canteen.city,
        address: canteen.address,
        coordinates: [
          canteen.latitude,
          canteen.longitude
        ]
      }.as_json)
    end

    context "with null latitude" do
      let(:canteen) { create :canteen, latitude: nil, longitude: 0.0 }

      it "answers with null coordinates" do
        get :index, format: :json
        expect(response.status).to eq(200)

        expect(json[0]).to eq({
          id: canteen.id,
          name: canteen.name,
          city: canteen.city,
          address: canteen.address,
          coordinates: nil
        }.as_json)
      end
    end

    context "with null longitude" do
      let(:canteen) { create :canteen, latitude: 0.0, longitude: nil }

      it "answers with null coordinates" do
        get :index, format: :json
        expect(response.status).to eq(200)

        expect(json[0]).to eq({
          id: canteen.id,
          name: canteen.name,
          city: canteen.city,
          address: canteen.address,
          coordinates: nil
        }.as_json)
      end
    end

    context "with both null coordinates" do
      let(:canteen) { create :canteen, latitude: nil, longitude: nil }

      it "answers with null coordinates" do
        get :index, format: :json
        expect(response.status).to eq(200)

        expect(json[0]).to eq({
          id: canteen.id,
          name: canteen.name,
          city: canteen.city,
          address: canteen.address,
          coordinates: nil
        }.as_json)
      end
    end

    it "adds link headers" do
      create_list :canteen, 10

      get :index, format: :json, params: {limit: 5}

      expect(response.status).to eq(200)
      expect(response.headers["Link"].to_s).to include('<http://test.host/api/v2/canteens?limit=5&page=1>; rel="first"')
      expect(response.headers["Link"].to_s).to include('<http://test.host/api/v2/canteens?limit=5&page=2>; rel="next"')
      expect(response.headers["Link"].to_s).to include('<http://test.host/api/v2/canteens?limit=5&page=3>; rel="last"')
    end

    context "should not included new canteens" do
      subject { json }

      before do
        create :canteen, state: "new"
        get :index, format: :json
      end

      it { is_expected.to be_an(Array) }
      it { is_expected.to have(1).item }
    end

    context "should not included disabled canteens" do
      subject { json }

      before do
        create :canteen, state: "archived"
        get :index, format: :json
      end

      it { is_expected.to be_an(Array) }
      it { is_expected.to have(1).item }
    end

    context "&limit" do
      it "limits list to given limit parameter" do
        create_list :canteen, 2
        expect(Canteen.count).to be > 2

        get :index, format: :json, params: {limit: 2}

        expect(response.status).to eq(200)
        expect(json.size).to eq(2)
      end

      xit "limits list to 1500 if given limit parameter exceed 1500" do
        # TODO: Some other test need instead of creating 1500+ canteens
        create_list :canteen, 1500
        expect(Canteen.count).to be > 1500

        get :index, format: :json, params: {limit: 3000}

        expect(response.status).to eq(200)
        expect(json.size).to eq(1500)
      end
    end

    context "&per_page" do
      xit "limits list to 500 canteens by default" do
        # TODO: Some other test need instead of creating 500+ canteens
        create_list :canteen, 500
        expect(Canteen.count).to be > 500

        get :index, format: :json

        expect(response.status).to eq(200)
        expect(json.size).to eq(500)
      end

      it "limits list to given limit parameter" do
        create_list :canteen, 5
        expect(Canteen.count).to be > 5

        get :index, format: :json, params: {per_page: 2}

        expect(response.status).to eq(200)
        expect(json.size).to eq(2)
      end

      xit "limits list to 1500 if given limit parameter exceed 1500" do
        # TODO: Some other test need instead of creating 1500+ canteens
        create_list :canteen, 1500
        expect(Canteen.count).to be > 1500

        get :index, format: :json, params: {per_page: 3000}

        expect(response.status).to eq(200)
        expect(json.size).to eq(1500)
      end
    end

    context "&near" do
      before do
        create :canteen, latitude: 0.0, longitude: 0.1
        create :canteen, latitude: 0.0, longitude: 0.2
      end

      it "finds canteens within distance around a point" do
        get :index, format: :json,
          params: {near: {lat: 0.0, lng: 0.15, dist: 100}}

        expect(json).to have(3).items
      end

      it "finds canteens within default distance around a point" do
        get :index, format: :json, params: {near: {lat: 0.05, lng: 0.1}}

        expect(json).to have(1).items
      end
    end

    context "&ids" do
      let(:second_canteen) { create :canteen }

      before do
        create :canteen
        second_canteen
        create :canteen
      end

      it "returns canteens with given ids" do
        get :index, format: :json,
          params: {ids: [canteen.id, second_canteen.id].join(",")}

        expect(json).to have(2).items
        expect(json[0]["id"]).to eq(canteen.id)
        expect(json[1]["id"]).to eq(second_canteen.id)
      end
    end

    context "&near[place]" do
      let(:griebnitzsee) do
        create :canteen,
          name: "Mensa Griebnitzsee",
          address: "August-Bebel-Str. 89, 14482 Potsdam",
          latitude: 52.3935353446923,
          longitude: 13.1278145313263
      end

      let(:palais) do
        create :canteen,
          name: "Mensa Am Neuen Palais",
          address: "Am Neuen Palais 10, Haus 12, 14469 Potsdam",
          latitude: 52.399,
          longitude: 13.01494
      end

      before do
        griebnitzsee
        palais
        stub_request(:get, "https://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=Potsdam")
          .to_return(->(_request) { File.new Rails.root.join("spec/mocks/nominatim.json").to_s })
      end

      it "returns canteens near a specified place" do
        get :index, format: :json, params: {near: {place: "Potsdam"}}

        expect(json).to have(2).item
        expect(json[0]["name"]).to eq(palais.name)
        expect(json[1]["name"]).to eq(griebnitzsee.name)
      end
    end

    context "&hasCoordinates" do
      let(:griebnitzsee) do
        create :canteen,
          name: "Mensa Griebnitzsee",
          address: "August-Bebel-Str. 89, 14482 Potsdam",
          latitude: 52.3935353446923,
          longitude: 13.1278145313263
      end

      let(:unknown) do
        create :canteen,
          name: "Mensa Am Neuen Palais",
          address: "Am Neuen Palais 10, Haus 12, 14469 Potsdam",
          latitude: nil,
          longitude: nil
      end

      before do
        griebnitzsee
        unknown
      end

      it "returns only canteens when hasCoordinates is true" do
        get :index, format: :json, params: {hasCoordinates: "true"}

        expect(json).to have(2).item
        expect(json[0]["name"]).to eq(canteen.name)
        expect(json[1]["name"]).to eq(griebnitzsee.name)
      end

      it "returns only canteens when hasCoordinates is false" do
        get :index, format: :json, params: {hasCoordinates: "false"}

        expect(json).to have(1).item
        expect(json[0]["name"]).to eq(unknown.name)
      end
    end
  end

  describe "GET show" do
    let!(:canteen) { create :canteen }

    before { get :show, format: :json, params: {id: canteen.id} }

    it "answers with canteen" do
      get :show, format: :json, params: {id: canteen.id}
      expect(response.status).to eq(200)

      expect(json).to eq({
        id: canteen.id,
        name: canteen.name,
        city: canteen.city,
        address: canteen.address,
        coordinates: [
          canteen.latitude,
          canteen.longitude
        ]
      }.as_json)
    end

    context "with a new canteen" do
      subject { json }

      let(:canteen) { create :canteen, state: "new" }

      context "response" do
        subject { response }

        its(:status) { is_expected.to eq 200 }
      end

      context "json" do
        subject { json }

        its(["id"]) { is_expected.to be canteen.id }
      end
    end

    context "with an archived canteens" do
      subject { json }

      let(:canteen) { create :canteen, state: "archived" }

      context "response" do
        subject { response }

        its(:status) { is_expected.to eq 200 }
      end

      context "json" do
        subject { json }

        its(["id"]) { is_expected.to be canteen.id }
      end
    end

    context "with a replaced canteen" do
      subject { json }

      let(:replacement) { create :canteen, state: "active" }
      let(:canteen) { create :canteen, state: "archived", replaced_by: replacement }

      context "response" do
        subject { response }

        its(:status) { is_expected.to eq 200 }
      end

      context "json" do
        subject { json }

        its(["id"]) { is_expected.to be replacement.id }
      end
    end
  end
end
