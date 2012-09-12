require 'spec_helper'

describe Api::V2::CanteensController do
  let(:json) { JSON.parse response.body }

  describe "GET index" do
    let(:canteen) { FactoryGirl.create :canteen }
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
        :latitude => canteen.latitude,
        :longitude => canteen.longitude
      }.as_json
    end

    it "should limit list to 100 canteens" do
      100.times { FactoryGirl.create :canteen }
      Canteen.count.should > 100

      get :index, format: :json

      response.status.should == 200
      json.should have(100).items
    end

    it "should limit list to given limit parameter" do
      100.times { FactoryGirl.create :canteen }
      Canteen.count.should > 100

      get :index, format: :json, limit: 20

      response.status.should == 200
      json.should have(20).items
    end

    it "should limit list to 100 if given limit parameter exceed 100" do
      100.times { FactoryGirl.create :canteen }
      Canteen.count.should > 100

      get :index, format: :json, limit: 120

      response.status.should == 200
      json.should have(100).items
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
        :latitude => canteen.latitude,
        :longitude => canteen.longitude
      }.as_json
    end
  end
end
