require 'spec_helper'

describe Api::V1::CafeteriasController do
  let(:json) { JSON[response.body] }

  describe "GET index" do
    let(:canteen) { FactoryGirl.create :canteen }
    before        { canteen }

    it "should return list of cafeterias" do
      get :index, format: :json

      response.status.should == 200
      json.should be_an(Array)
      json.should have(1).item
    end

    context "a cafeteria" do
      it "should be same as single resource" do
        get :index, format: :json
        caf = json[0]

        get :show, format: :json, id: caf["cafeteria"]["id"]

        caf.should == JSON[response.body]
      end
    end
  end

  describe "GET show" do
    let(:canteen) { FactoryGirl.create :canteen }

    it "should return a cafeteria object" do
      get :show, format: :json, id: canteen.id

      response.status.should == 200
      json.should be_an(Hash)

      json["cafeteria"]["id"].should == canteen.id
    end

    it "should include cafeteria id" do
      get :show, format: :json, id: canteen.id
      json["cafeteria"]["id"].should == canteen.id
    end

    it "should include cafeteria name" do
      get :show, format: :json, id: canteen.id
      json["cafeteria"]["name"].should == canteen.name
    end

    it "should include cafeteria address" do
      get :show, format: :json, id: canteen.id
      json["cafeteria"]["address"].should == canteen.address
    end

    it "should include todays and tomorrows meals" do
      FactoryGirl.create :meal, day: FactoryGirl.create(:day, canteen: canteen, date: Time.zone.now - 2.day)
      FactoryGirl.create :meal, day: FactoryGirl.create(:yesterday, canteen: canteen)
      FactoryGirl.create :meal, day: FactoryGirl.create(:today, canteen: canteen)
      FactoryGirl.create :meal, day: FactoryGirl.create(:tomorrow, canteen: canteen)
      FactoryGirl.create :meal, day: FactoryGirl.create(:day, canteen: canteen, date: Time.zone.now + 2.day)

      get :show, format: :json, id: canteen.id

      json["cafeteria"]["meals"].should be_an(Array)
      json["cafeteria"]["meals"].should have(2).items
      json["cafeteria"]["meals"].each do |meal|
        date = meal["meal"]["date"].to_time
        date.should >= (Time.zone.now).to_date
        date.should <  (Time.zone.now + 2.days).to_date
      end
    end
  end
end
