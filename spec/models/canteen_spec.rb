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
      Timecop.freeze Time.zone.local(2012, 04, 16, 8, 5, 3)
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

    it "should fetch meals with explicit today = false option" do
      canteen.url = "http://example.com/feed_v2.xml"
      canteen.fetch option: false
      canteen.meals.should have(9).items
    end

    it "should remove old meals" do
      FactoryGirl.create(:meal,
        day: FactoryGirl.create(:day,
          canteen: canteen,
          date: Date.new(2012, 05, 29)),
        category: 'Essen 1')
      canteen.meals.should have(1).items

      canteen.fetch
      canteen.meals(true).should have(9).items
    end

    it 'should use the today_url if today is true' do
      canteen.url = 'now allowed'
      canteen.today_url = "http://example.com/canteen_feed.xml"
      canteen.fetch today: true
      canteen.meals.should have(9).items
    end
  end

  describe '#fetch_if_neede' do
    context 'should not fetch' do
      before { canteen.should_not_receive(:fetch) }

      it 'if the earlier than first fetch hour' do
        Timecop.freeze Time.zone.local(2012, 04, 16, 7, 59, 59)
        canteen.fetch_if_needed.should be_false
      end

      it 'if the later than 13 o\'clock pm' do
        Timecop.freeze Time.zone.local(2012, 04, 16, 15, 00, 00)
        canteen.fetch_if_needed.should be_false
      end
    end

    context 'should fetch' do
      before { Timecop.freeze Time.zone.local(2012, 04, 16, 12, 0, 0) }

      it 'full without a last_fetched_at today' do
        canteen.last_fetched_at = DateTime.new(2012, 04, 14, 23, 0, 0)
        canteen.should_receive(:fetch).with(today: false).and_return true
        canteen.fetch_if_needed.should be_true
      end

      it 'full without a successful fetch' do
        canteen.last_fetched_at = nil
        canteen.should_receive(:fetch).with(today: false).and_return true
        canteen.fetch_if_needed.should be_true
      end

      it 'today after a successful fetch' do
        canteen.last_fetched_at = Time.zone.local(2012, 04, 16, 8, 4, 0)
        canteen.should_receive(:fetch).with(today: true).and_return true
        canteen.fetch_if_needed.should be_true
      end
    end
  end

  describe '#fetch_state' do
    subject { canteen.fetch_state }

    context 'when canteen is disabled' do
      before do
        canteen.update_attribute :active, false
      end

      it { should eq :out_of_order }
    end

    context 'when updated in the last 24 hours' do
      before do
        canteen.update_attribute :last_fetched_at, Time.zone.now - 4.hour
      end

      it { should eq :fetch_up_to_date }
    end

    context 'when updated earlier than 24 hours ago' do
      before do
        canteen.update_attribute :last_fetched_at, Time.zone.now - 25.hour
      end

      it { should eq :fetch_needed }
    end

    context 'when never updated' do
      before do
        canteen.update_attribute :last_fetched_at, nil
      end

      it { should eq :no_fetch_ever }
    end
  end
end
