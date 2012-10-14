require 'spec_helper'

describe Api::V2::DaysController do
  render_views

  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:day) { FactoryGirl.create :day }
    let(:canteen) { day.canteen }
    before { day }

    it "should answer with a list" do
      get :index, canteen_id: canteen.id, format: :json
      response.status.should == 200

      json.should be_an(Array)
      json.should have(1).item
    end

    it "should answer with a list of day nodes" do
      get :index, canteen_id: canteen.id, format: :json
      response.status.should == 200

      json[0].should == {
        :date => day.date.iso8601,
        :closed => day.closed
      }.as_json
    end

    context "&start" do
      let(:today) { FactoryGirl.create :today, closed: true }
      let(:canteen) { today.canteen }
      let(:tomorrow) { FactoryGirl.create :tomorrow, canteen: canteen }
      let(:yesterday) { FactoryGirl.create :yesterday, canteen: canteen }

      before do
        today && tomorrow && yesterday
        FactoryGirl.create :day, canteen: canteen, date: yesterday.date - 1
        FactoryGirl.create :day, canteen: canteen, date: yesterday.date - 2
        FactoryGirl.create :day, canteen: canteen, date: tomorrow.date + 1
      end

      it "should default to today if not given" do
        get :index, canteen_id: canteen.id, format: :json

        json.should have(3).items
        json[0]['date'].should == today.date.iso8601
        json[1]['date'].should == tomorrow.date.iso8601
        json[2]['date'].should == (tomorrow.date + 1).iso8601
      end
    end
  end

  describe "GET show" do
    let(:day) { FactoryGirl.create :day }
    let(:canteen) { day.canteen }
    before { canteen }

    it "should answer with day" do
      get :show, canteen_id: canteen.id, id: day.id, format: :json
      response.status.should == 200

      json.should == {
        :date => day.date.iso8601,
        :closed => day.closed
      }.as_json
    end
  end
end
