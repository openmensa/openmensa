require 'spec_helper'

describe Api::V1::CafeteriasController do
  render_views

  let(:json) { JSON[response.body] }

  describe "GET index" do
    let(:cafeteria) { FactoryGirl.create :cafeteria }
    before          { cafeteria }

    it "should return list of cafeterias" do
      get :index, format: :json

      response.status.should == 200
      json.should be_an(Array)
      json.should have(1).item

      json[0] == JSON[]
    end

    context "a cafeteria" do
      it "should be same as single resource" do
        get :index, format: :json
        caf = json[0]

        get :show, format: :json, id: cat["cafeteria"]["id"]
        caf.should == json
      end
    end
  end

  describe "GET show" do
    let(:cafeteria) { FactoryGirl.create :cafeteria }

    it "should return a cafeteria object" do
      get :show, format: :json, id: cafeteria.id

      response.status.should == 200
      json.should be_an(Hash)

      json["cafeteria"]["id"].should == cafeteria.id
    end

    it "should include cafeteria id" do
      get :show, format: :json, id: cafeteria.id
      json["cafeteria"]["id"].should == cafeteria.id
    end

    it "should include cafeteria name" do
      get :show, format: :json, id: cafeteria.id
      json["cafeteria"]["name"].should == cafeteria.name
    end

    it "should include cafeteria address" do
      get :show, format: :json, id: cafeteria.id
      json["cafeteria"]["address"].should == cafeteria.address
    end

    it "should include todays and tomorrows meals" do
      FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now - 2.day
      FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now - 1.day
      FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now
      FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now + 1.day
      FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now + 2.day

      get :show, format: :json, id: cafeteria.id

      json["cafeteria"]["meals"].should be_an(Array)
      json["cafeteria"]["meals"].should have(2).items
      json["cafeteria"]["meals"].each do |meal|
        date = meal["date"].to_time
        date.should >= (Time.zone.now).to_date
        date.should <  (Time.zone.now + 2.days).to_date
      end
    end
  end
end
