require 'spec_helper'

describe Canteen do
  let(:canteen) { FactoryGirl.create :canteen }

  it { should_not accept_values_for(:name, nil, "") }
  it { should_not accept_values_for(:address, nil, "") }

  describe "#fetch" do
    before do
      stub_request(:any, "example.com/canteen_feed.xml").
        to_return(:body => mock_file("canteen_feed.xml"), :status => 200)
      stub_request(:any, "example.com/feed_v2.xml").
        to_return(:body => mock_file("feed_v2.xml"), :status => 200)
    end

    it "should fetch meals from remote source (version 1.0)" do
      canteen.url = "http://example.com/canteen_feed.xml"
      canteen.fetch
      canteen.meals.should have(9).items
    end
    
    it "should fetch meals from remote source (version 2.0)" do
      canteen.url = "http://example.com/feed_v2.xml"
      canteen.fetch
      canteen.meals.should have(9).items
    end

    it "should remove old meals" do
      FactoryGirl.create(:meal,
        canteen: canteen,
        date: Date.new(2012, 05, 29),
        category: 'Essen 1')
      canteen.meals.should have(1).items

      canteen.fetch
      canteen.meals(true).should have(9).items
    end
  end
end
