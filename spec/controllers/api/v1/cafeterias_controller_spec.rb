require 'spec_helper'

describe Api::V1::CafeteriasController do
  render_views

  let(:json) { JSON[response.body] }

  describe "GET /" do
    let(:cafeteria) { FactoryGirl.create :cafeteria }
    before          { cafeteria }

    it "should return list of cafeterias" do
      get :index, format: :json

      response.status.should == 200
      json.should be_an(Array)
      json.should have(Cafeteria.count).item
    end

    context "a mensa node" do
      before do
        FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now - 2.day
        FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now - 1.day
        FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now
        FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now + 1.day
        FactoryGirl.create :meal, cafeteria: cafeteria, date: Time.zone.now + 2.day
      end

      it "should include todays and tomorrows meals" do
        get :index, format: :json

        json[0]["cafeteria"]["meals"].should be_an(Array)
        json[0]["cafeteria"]["meals"].should have(3).items
        json[0]["cafeteria"]["meals"].each do |meal|
          date = meal["date"].to_time
          date.should >= (Time.zone.now - 1.day).to_date
          date.should <  (Time.zone.now + 2.days).to_date
        end
      end
    end
  end
end
