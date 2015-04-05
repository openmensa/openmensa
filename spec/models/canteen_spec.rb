require 'spec_helper'

describe Canteen, type: :model do
  let(:canteen) { FactoryGirl.create :canteen }

  it { is_expected.not_to accept_values_for(:name, nil, '') }
  it { is_expected.not_to accept_values_for(:address, nil, '') }

  describe '#fetch' do
    before do
      stub_request(:any, 'example.com/canteen_feed.xml')
        .to_return(body: mock_file('canteen_feed.xml'), status: 200)
      stub_request(:any, 'example.com/feed_v2.xml')
        .to_return(body: mock_file('feed_v2.xml'), status: 200)
      stub_request(:any, 'example.com/feed_v21.xml')
        .to_return(body: mock_file('feed_v21.xml'), status: 200)
      Timecop.freeze Time.zone.local(2012, 04, 16, 8, 5, 3)
    end

    it 'should fetch meals from remote source (version 1.0)' do
      canteen.url = 'http://example.com/canteen_feed.xml'
      canteen.fetch
      expect(canteen.meals).to have(9).items
    end

    it 'should fetch meals from remote source (version 2.0)' do
      canteen.url = 'http://example.com/feed_v2.xml'
      canteen.fetch
      expect(canteen.meals).to have(9).items
    end

    it 'should fetch meals from remote source (version 2.1)' do
      canteen.url = 'http://example.com/feed_v21.xml'
      canteen.fetch
      expect(canteen.meals).to have(9).items
    end

    it 'should fetch meals with explicit today = false option' do
      canteen.url = 'http://example.com/feed_v2.xml'
      canteen.fetch option: false
      expect(canteen.meals).to have(9).items
    end

    it 'should remove old meals' do
      FactoryGirl.create(:meal,
        day: FactoryGirl.create(:day,
          canteen: canteen,
          date: Date.new(2012, 05, 29)),
        category: 'Essen 1')
      expect(canteen.meals).to have(1).items

      canteen.fetch
      expect(canteen.meals(true)).to have(9).items
    end

    it 'should use the today_url if today is true' do
      canteen.url = 'now allowed'
      canteen.today_url = 'http://example.com/canteen_feed.xml'
      canteen.fetch today: true
      expect(canteen.meals).to have(9).items
    end
  end

  describe '#fetch_if_neede' do
    context 'should not fetch' do
      before { expect(canteen).to_not receive(:fetch) }

      it 'if the earlier than first fetch hour' do
        Timecop.freeze Time.zone.local(2012, 04, 16, 7, 59, 59)
        expect(canteen.fetch_if_needed).to be_falsey
      end

      it 'if the later than 13 o\'clock pm' do
        Timecop.freeze Time.zone.local(2012, 04, 16, 15, 00, 00)
        expect(canteen.fetch_if_needed).to be_falsey
      end
    end

    context 'should fetch' do
      before { Timecop.freeze Time.zone.local(2012, 04, 16, 12, 0, 0) }

      it 'full without a last_fetched_at today' do
        canteen.last_fetched_at = DateTime.new(2012, 04, 14, 23, 0, 0)
        expect(canteen).to receive(:fetch).with(today: false).and_return true
        expect(canteen.fetch_if_needed).to be_truthy
      end

      it 'full without a successful fetch' do
        canteen.last_fetched_at = nil
        expect(canteen).to receive(:fetch).with(today: false).and_return true
        expect(canteen.fetch_if_needed).to be_truthy
      end

      it 'today after a successful fetch' do
        canteen.last_fetched_at = Time.zone.local(2012, 04, 16, 8, 4, 0)
        expect(canteen).to receive(:fetch).with(today: true).and_return true
        expect(canteen.fetch_if_needed).to be_truthy
      end
    end
  end

  describe '#fetch_state' do
    subject { canteen.fetch_state }

    context 'when canteen is disabled' do
      before do
        canteen.update_attribute :active, false
      end

      it { is_expected.to eq :out_of_order }
    end

    context 'when updated in the last 24 hours' do
      before do
        canteen.update_attribute :last_fetched_at, Time.zone.now - 4.hour
      end

      it { is_expected.to eq :fetch_up_to_date }
    end

    context 'when updated earlier than 24 hours ago' do
      before do
        canteen.update_attribute :last_fetched_at, Time.zone.now - 25.hour
      end

      it { is_expected.to eq :fetch_needed }
    end

    context 'when never updated' do
      before do
        canteen.update_attribute :last_fetched_at, nil
      end

      it { is_expected.to eq :no_fetch_ever }
    end
  end
end
