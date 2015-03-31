require 'spec_helper'
include Nokogiri

describe OpenMensa::Updater do
  let(:canteen) { FactoryGirl.create :canteen }
  let(:updater) { OpenMensa::Updater.new(canteen, version: 2) }
  let(:today) { FactoryGirl.create :today, canteen: canteen }
  let(:document) { XML::Document.new }
  let(:root_element) do
    n = XML::Node.new('openmensa', document)
    document.root = n
    n
  end
  before { Timecop.freeze DateTime.new(2012, 04, 16, 8, 5, 3) }

  context '#fetch' do
    before do
      stub_request(:any, 'example.com/canteen_feed.xml')
        .to_return(body: mock_file('canteen_feed.xml'), status: 200)
      stub_request(:any, 'example.com/data.xml')
        .to_return(body: '<xml>', status: 200)
      stub_request(:any, 'example.com/301.xml')
        .to_return(status: 301, headers: {location: 'http://example.com/data.xml'})
      stub_request(:any, 'example.com/302.xml')
        .to_return(status: 302, headers: {location: 'http://example.com/data.xml'})
      stub_request(:any, 'example.com/500.xml')
        .to_return(status: 500)
      stub_request(:any, 'unknowndomain.org')
        .to_raise(SocketError.new('getaddrinfo: Name or service not known'))
      stub_request(:any, 'example.org/timeout.xml')
        .to_timeout
    end

    it 'should skip on missing urls' do
      canteen.update_attribute :url, nil
      expect(canteen.url).to be_nil
      expect(updater.fetch!).to be_falsey
    end

    it 'should skip invalid urls' do
      canteen.update_attribute :url, ':///:asdf'
      expect(updater.fetch!).to be_falsey
      m = canteen.messages.first
      expect(m).to be_an_instance_of(FeedInvalidUrlError)
      expect(updater.errors).to eq([m])
    end

    it 'should receive feed data via http' do
      canteen.update_attribute :url, 'http://example.com/data.xml'
      expect(updater.fetch!.read).to eq('<xml>')
    end

    it 'should update feed url on 301 responses' do
      canteen.update_attribute :url, 'http://example.com/301.xml'
      expect(updater.fetch!.read).to eq('<xml>')
      expect(canteen.url).to eq('http://example.com/data.xml')
      m = canteen.messages.first
      expect(m).to be_an_instance_of(FeedUrlUpdatedInfo)
      expect(m.old_url).to eq('http://example.com/301.xml')
      expect(m.new_url).to eq('http://example.com/data.xml')
    end

    it 'should not update feed url on 302 responses' do
      canteen.update_attribute :url, 'http://example.com/302.xml'
      expect(updater.fetch!.read).to eq('<xml>')
      expect(canteen.url).to eq('http://example.com/302.xml')
    end

    it 'should handle http errors correctly' do
      canteen.update_attribute :url, 'http://example.com/500.xml'
      expect(updater.fetch!).to be_falsey
      m = canteen.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(500)
      expect(updater.errors).to eq([m])
    end

    it 'should handle network errors correctly' do
      canteen.update_attribute :url, 'http://unknowndomain.org'
      expect(updater.fetch!).to be_falsey
      m = canteen.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(nil)
      expect(updater.errors).to eq([m])
    end

    it 'should handle network timeout ' do
      canteen.update_attribute :url, 'http://example.org/timeout.xml'
      expect(updater.fetch!).to be_falsey
      m = canteen.messages.first
      expect(m).to be_an_instance_of(FeedFetchError)
      expect(m.code).to eq(nil)
      expect(updater.errors).to eq([m])
    end
  end

  context 'should reject' do
    it 'non-xml data' do
      allow(updater).to receive(:data).and_return mock_content('feed_garbage.dat')
      expect(updater.parse!).to be_falsey

      canteen.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:no_xml)
        expect(message.version).to eq(nil)
        expect(updater.errors).to eq([message])
      end
    end

    it 'well-formatted but non-valid xml data' do
      allow(updater).to receive(:data).and_return mock_content('feed_wellformated.xml')
      updater.parse!
      expect(updater.validate!).to be_falsey

      canteen.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:invalid_xml)
        expect(message.version).to eq(1)
        expect(updater.errors).to eq([message])
      end
    end

    it 'valid but non-openmensa xml data' do
      allow(updater).to receive(:data).and_return mock_content('carrier_ship.xml')
      updater.parse!
      expect(updater.validate!).to be_falsey

      canteen.messages.first.tap do |message|
        expect(message).to be_a(FeedValidationError)
        expect(message.kind).to eq(:unknown_version)
        expect(message.version).to eq(nil)
        expect(updater.errors).to eq([message])
      end
    end
  end

  it 'should return 1 on valid v1 openmensa xml feeds' do
    allow(updater).to receive(:data).and_return mock_content('canteen_feed.xml')
    updater.parse!
    expect(updater.validate!).to eq(1)
  end

  it 'should return 2 on valid v openmensa xml feeds' do
    allow(updater).to receive(:data).and_return mock_content('feed_v2.xml')
    updater.parse!
    expect(updater.validate!).to eq(2)
  end

  context 'with valid v2 feed' do
    it 'ignore empty feeds' do
      allow(updater).to receive(:data).and_return mock_content('feed2_empty.xml')
      updater.parse!

      expect do
        updater.update_canteen updater.document.root.child.next
      end.to_not change { canteen.last_fetched_at }
    end

    context 'with new data' do
      it 'should add a new meals to a day' do
        meal_name = 'Essen 1'
        meal_category = 'Hauptgricht'

        root_element << meal = xml_meal(meal_name)
        meal << xml_text('note', 'vegan')
        meal << xml_text('note', 'vegetarisch')
        meal << t = xml_text('price', '1.70'); t['role'] = 'student'
        meal << t = xml_text('price', '2.70'); t['role'] = 'other'
        expect(today.meals.size).to be_zero

        updater.add_meal(today, meal_category, meal)

        expect(today.meals.size).to eq(1)
        expect(today.meals.first.name).to eq(meal_name)
        expect(today.meals.first.prices[:student]).to eq(1.7)
        expect(today.meals.first.prices[:other]).to eq(2.7)
        expect(today.meals.first.notes.map(&:name)).to match_array(%w(vegan vegetarisch))

        expect(updater.added_meals).to eq(1)
        expect(updater).to be_changed
      end

      it 'should add a new day with meals entries' do
        # data
        category1_name = 'Hauptgricht'
        category1_meal1_name = 'Essen 1'
        category1_meal2_name = 'Essen 2'

        category2_name = 'Beilagen'
        category2_meal1_name = 'Beilage 1'

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = Time.zone.today.to_s

        day << category = xml_node('category')
        category['name'] = category1_name
        category << xml_meal(category1_meal1_name)
        category << xml_meal(category1_meal2_name)

        day << category = xml_node('category')
        category['name'] = category2_name
        category << xml_meal(category2_meal1_name)

        # starting check
        expect(canteen.days.size).to be_zero

        updater.add_day(day)

        expect(canteen.days.size).to eq(1)
        day = canteen.days.first
        expect(day.meals.size).to eq(3)
        expect(day.meals.order(:pos).map(&:name)).to eq([category1_meal1_name, category1_meal2_name, category2_meal1_name])
        expect(day.meals.order(:pos).pluck(:pos)).to eq([1, 2, 3])

        expect(updater.added_days).to eq(1)
        expect(updater).to be_changed
      end

      it 'should add closed days entries' do
        # build xml data
        root_element << day = xml_node('day')
        day['date'] = Time.zone.today.to_s
        day << xml_node('closed')

        # starting check
        expect(canteen.days.size).to be_zero

        updater.add_day(day)

        expect(canteen.days.size).to eq(1)
        day = canteen.days.first
        expect(day).to be_closed
        expect(day.meals.size).to be_zero

        expect(updater.added_days).to eq(1)
        expect(updater).to be_changed
      end

      it 'should update last_fetch_at and not last_changed_at' do
        allow(updater).to receive(:data).and_return mock_content('feed_v2.xml')
        updater.parse!

        canteen.update_attribute :last_fetched_at, Time.zone.now - 1.day
        updated_at = canteen.updated_at

        updater.update_canteen updater.document.root.child.next

        expect(canteen.days.size).to eq(4)
        expect(canteen.last_fetched_at).to be > Time.zone.now - 1.minute
        expect(canteen.updated_at).to eq(updated_at)
      end

      it 'should not add dates in the past' do
        # build xml data
        root_element << day = xml_node('day')
        day['date'] = (Time.zone.today - 2.days).to_s
        day << xml_node('closed')

        # starting check
        expect(canteen.days.size).to be_zero

        updater.add_day(day)

        expect(canteen.days.size).to be_zero

        expect(updater.added_days).to eq(0)
        expect(updater).not_to be_changed
      end

      it 'should add information about today' do
        # build xml data
        root_element << day = xml_node('day')
        day['date'] = Date.today.to_s
        day << xml_node('closed')

        # starting check
        expect(canteen.days.size).to be_zero

        updater.add_day(day)

        expect(canteen.days.size).to eq(1)

        expect(updater.added_days).to eq(1)
        expect(updater).to be_changed
      end
    end

    context 'with old data' do
      it 'should allow to close the canteen on given days' do
        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << xml_node('closed')
        meal = FactoryGirl.create :meal, day: today

        # starting check
        expect(today.meals.size).to eq(1)
        expect(today).not_to be_closed

        updater.update_day(today, day)

        expect(today.meals.size).to be_zero
        expect(today).to be_closed

        expect(updater.updated_days).to eq(1)
        expect(updater).to be_changed
      end

      it 'should allow to reopen a canteen on given days' do
        # data
        category_name = 'Hauptessen'
        meal_name = 'Essen 1'

        # close our test day
        today.update_attribute :closed, true

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << category = xml_node('category')
        category['name'] = category_name
        category <<  xml_meal(meal_name)

        # starting check
        expect(today.meals.size).to eq(0)
        expect(today).to be_closed

        updater.update_day(today, day)

        expect(today.meals.size).to eq(1)
        expect(today).not_to be_closed

        expect(updater.updated_days).to eq(1)
        expect(updater).to be_changed
      end

      it 'should add new meals' do
        # data
        category_name = 'Hauptessen'
        meal_name = 'Essen 1'

        # close our test day
        meal = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << category = xml_node('category')
        category['name'] = meal.category
        category << xml_meal(meal.name)
        day << category = xml_node('category')
        category['name'] = category_name
        category << xml_meal(meal_name)

        # starting check
        expect(today.meals.size).to eq(1)

        updater.update_day(today, day)

        expect(today.meals.size).to eq(2)
        expect(today.meals.order(:pos).pluck(:name)).to eq([meal.name, meal_name])
        expect(today.meals.order(:pos).pluck(:pos)).to eq([1, 2])

        expect(updater).to be_changed
        expect(updater.added_meals).to eq(1)
      end

      it 'should update changed meals' do
        meal1 = FactoryGirl.create :meal, day: today, prices: {student: 1.8, employee: 2.9, other: nil, pupil: nil}
        meal1.notes = %w(vegan vegetarisch)

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << category = xml_node('category')
        category['name'] = meal1.category
        category << meal = xml_meal(meal1.name)
        meal << xml_text('note', 'vegan')
        meal << xml_text('note', 'scharf')
        meal << t = xml_text('price', '1.70'); t['role'] = 'student'
        meal << t = xml_text('price', '2.70'); t['role'] = 'other'

        # starting check
        expect(today.meals.size).to eq(1)
        updated_at = today.meals.first.updated_at - 1.second

        updater.update_day(today, day)

        expect(today.meals.size).to eq(1)
        expect(today.meals.first.prices).to eq(student: 1.7, other: 2.7)
        expect(today.meals.first.notes.map(&:name)).to match_array(%w(vegan scharf))
        expect(today.meals.first.name).to eq(meal1.name)
        expect(today.meals.first.updated_at).to be > updated_at
        expect(updater.updated_meals).to eq(1)
      end

      it 'should not update unchanged meals' do
        # close our test day
        meal1 = FactoryGirl.create :meal, day: today, prices: {student: 1.8, employee: 2.9, other: nil, pupil: nil}
        meal1.notes = %w(vegan vegetarisch)

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << category = xml_node('category')
        category['name'] = meal1.category
        category << meal = xml_meal(meal1.name)
        meal << xml_text('note', 'vegan')
        meal << xml_text('note', 'vegetarisch')
        meal << t = xml_text('price', '1.80'); t['role'] = 'student'
        meal << t = xml_text('price', '2.90'); t['role'] = 'employee'

        # starting check
        expect(today.meals.size).to eq(1)
        updated_at = today.meals.first.updated_at

        updater.update_day(today, day)

        expect(today.meals.size).to eq(1)
        expect(today.meals.first.prices).to eq(student: 1.8, employee: 2.9)
        expect(today.meals.first.notes.map(&:name)).to match_array(%w(vegan vegetarisch))
        expect(today.meals.first.name).to eq(meal1.name)
        expect(today.meals.first.updated_at).to eq(updated_at)
        expect(updater.updated_meals).to eq(0)
      end

      it 'should drop disappeared meals' do
        # close our test day
        meal1 = FactoryGirl.create :meal, day: today
        meal2 = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << category = xml_node('category')
        category['name'] = meal2.category
        category << xml_meal(meal2.name)

        # starting check
        expect(today.meals.size).to eq(2)
        ids = today.meals.map(&:id)

        updater.update_day(today, day)

        expect(today.meals(force_reload = true).size).to eq(1)
        expect(today.meals.first).to eq(meal2)

        expect(ids.map {|id| Meal.find_by_id id }).to match_array([meal2, nil])

        expect(updater.removed_meals).to eq(1)
        expect(updater).to be_changed
      end

      it 'should not update last_changed_at on unchanged meals' do
        # close our test day
        meal1 = FactoryGirl.create :meal, day: today

        # build xml data
        root_element << day = xml_node('day')
        day['date'] = today.date.to_s
        day << category = xml_node('category')
        category['name'] = meal1.category
        category << xml_meal(meal1.name)

        # starting check
        expect(today.meals.size).to eq(1)
        updated_at = meal1.updated_at

        updater.update_day(today, day)

        expect(today.meals.size).to eq(1)
        expect(meal1.updated_at).to eq(updated_at)
      end

      it 'should update last_fetch_at and not last_changed_at' do
        allow(updater).to receive(:data).and_return mock_content('feed_v2.xml')
        updater.parse!

        day1 = FactoryGirl.create :day, date: Date.new(2012, 05, 22), canteen: canteen
        meal1 = FactoryGirl.create :meal, day: day1, name: 'Tagessuppe'
        day2 = FactoryGirl.create :day, date: Date.new(2012, 05, 29), canteen: canteen
        meal2 = FactoryGirl.create :meal, day: day2
        meal3 = FactoryGirl.create :meal, day: day2
        meal4 = FactoryGirl.create :meal, day: today

        canteen.update_attribute :last_fetched_at, Time.zone.now - 1.day
        expect(canteen.days.size).to eq(3)
        expect(canteen.meals.size).to eq(4)

        updated_at = canteen.updated_at

        updater.update_canteen updater.document.root.child.next

        expect(canteen.days.size).to eq(5)
        expect(canteen.meals.size).to eq(10)
        expect(canteen.last_fetched_at).to be > Time.zone.now - 1.minute
        expect(canteen.updated_at).to eq(updated_at)
      end

      it 'should set last_fetched_at on unchanged feed data with days' do
        allow(updater).to receive(:data).and_return mock_content('feed_v2.xml')
        updater.parse!

        updater.update_canteen updater.document.root.child.next

        expect(canteen.days.size).to eq(4)
        expect(canteen.meals.size).to eq(9)

        last_fetched_at = canteen.last_fetched_at
        updated_at = canteen.updated_at

        Timecop.freeze Time.now + 1.hour

        updater.update_canteen updater.document.root.child.next

        expect(canteen.last_fetched_at).to be > last_fetched_at
        expect(canteen.updated_at).to eq(updated_at)
      end

      it 'should not update days in the past' do
        d = FactoryGirl.create :day, date: (Date.today - 2.days), canteen: canteen
        # build xml data
        root_element << day = xml_node('day')
        day['date'] = d.date.to_s
        day << xml_node('closed')

        # starting check
        expect(canteen.days.size).to eq(1)

        updater.update_day(d, day)

        expect(canteen.days.size).to eq(1)

        expect(updater).not_to be_changed
      end

      it 'should update today' do
        d = FactoryGirl.create :day, date: Date.today, canteen: canteen
        # build xml data
        root_element << day = xml_node('day')
        day['date'] = d.date.to_s
        day << xml_node('closed')

        # starting check
        expect(canteen.days.size).to eq(1)
        expect(canteen.days.first).not_to be_closed

        updater.update_day(d, day)

        expect(canteen.days.size).to eq(1)
        expect(canteen.days.first).to be_closed

        expect(updater).to be_changed
      end
    end

    context '#update' do
      before do
        stub_request(:any, 'example.org/compact.xml')
          .to_return(body: mock_file('feed2_compact.xml'), status: 200)
        stub_request(:any, 'example.org/double.xml')
          .to_return(body: mock_file('feed2_doubleMeals.xml'), status: 200)
      end

      it 'should handle compact document' do
        canteen.url = 'http://example.org/compact.xml'
        expect(updater.update).to be_truthy
        expect(canteen.days.size).to eq(1)
        expect(canteen.meals.size).to eq(4)
      end

      it 'should merge double meal names correctly' do
        canteen.url = 'http://example.org/double.xml'
        expect(updater.update).to be_truthy
        expect(canteen.days.size).to eq(1)
        expect(canteen.meals.size).to eq(3)
        expect(updater.update).to be_truthy
        expect(canteen.days.size).to eq(1)
        expect(canteen.meals.size).to eq(3)
      end

      it 'should not change data on same feed' do
        canteen.url = 'http://example.org/compact.xml'
        # first
        expect(updater.update).to be_truthy
        updater.reset_stats
        # second
        expect(updater.update).to be_truthy
        expect(updater.added_days).to eq(0)
        expect(updater.updated_days).to eq(0)
        expect(updater.added_meals).to eq(0)
        expect(updater.updated_meals).to eq(0)
        expect(updater.removed_meals).to eq(0)
        expect(updater).not_to be_changed
      end
    end
  end
end
