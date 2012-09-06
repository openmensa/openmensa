# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe "canteens/show.html.haml" do
  let(:user) { FactoryGirl.create :user }
  let(:canteen) { FactoryGirl.create(:canteen) }

  before do
    assign(:user, user)
    assign(:canteen, canteen)
    assign(:date, Time.zone.now.to_date)
  end

  it "should contain canteen name" do
    render
    rendered.should include(canteen.name)
  end

  context 'without meals' do
    it "should list information about missing meal" do
      render

      rendered.should include('keine Angebote')
    end
  end


  context "on closed day" do
    let(:day) { FactoryGirl.create(:closed_day) }
    let(:canteen) { day.canteen }

    it "should show a closed notice" do
      render

      rendered.should include('geschlossen')
    end
  end
end
