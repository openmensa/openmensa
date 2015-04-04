
FactoryGirl.define do
  factory :user do
    sequence(:login) {|n| "user#{n}" }
    name 'John Doe'
    developer false

    after(:create) do |user|
      FactoryGirl.create(:identity, user: user)
    end
  end

  factory :admin, parent: :user do
    admin true
  end

  factory :developer, parent: :user do
    email { "#{login}@example.org" }
    developer true
  end

  factory :identity do
    association :user

    sequence(:uid) {|n| n.to_s.hash.to_s.gsub(/\D/, '') }
    provider 'twitter'
    token 'apiToken'
  end

  factory :application, class: 'Doorkeeper::Application' do
    sequence(:name)         {|n| "OAuth2 Client ##{n}" }
    sequence(:redirect_uri) {|n| "http://test.host/c#{n}/cb" }
  end

  factory :canteen do
    sequence(:name) {|n| "Mensa ##{n}" }
    address 'Marble Street, 12345 City'
    url 'http://example.com/canteen_feed.xml'
    city 'City'

    sequence(:latitude)  {|n| (n % 180) - 90 }
    sequence(:longitude) {|n| (n % 360) - 180 }

    association :user

    trait :with_meals do
      after(:create) do |canteen|
        FactoryGirl.create :yesterday, :with_meals, canteen: canteen
        FactoryGirl.create :today, :with_meals, canteen: canteen
        FactoryGirl.create :tomorrow, :with_meals, canteen: canteen
      end
    end

    trait :with_unordered_meals do
      after(:create) do |canteen|
        FactoryGirl.create :yesterday, :with_unordered_meals, canteen: canteen
        FactoryGirl.create :today, :with_unordered_meals, canteen: canteen
        FactoryGirl.create :tomorrow, :with_unordered_meals, canteen: canteen
      end
    end
  end

  factory :disabled_canteen, parent: :canteen do
    active false
  end

  factory :day do
    date { Time.zone.now }

    association :canteen

    trait :closed do
      closed true
    end

    trait :with_meals do
      after(:create) do |day|
        FactoryGirl.create :meal, day: day
        FactoryGirl.create :meal, day: day
        FactoryGirl.create :meal, day: day
      end
    end

    trait :with_unordered_meals do
      after(:create) do |day|
        FactoryGirl.create :meal, day: day, pos: 2
        FactoryGirl.create :meal, day: day, pos: 1
        FactoryGirl.create :meal, day: day, pos: 3
      end
    end
  end

  factory :yesterday, parent: :day do
    date { Time.zone.now - 1.day }
  end

  factory :today, parent: :day do
    date { Time.zone.now }
  end

  factory :tomorrow, parent: :day do
    date { Time.zone.now + 1.day }
  end

  factory :meal do
    sequence(:category) {|n| "Meal ##{n}" }
    name                { "The name of #{category}." }
    sequence(:price_student) {|n| 0.51 + n * 0.2 }

    association :day

    trait :with_notes do
      notes ['Note M1', 'Note M2', 'Note M3']
    end
  end

  factory :note do
    sequence(:name)     {|n| "note #{n}" }
  end

  factory :feedInvalidUrlError do
    association :canteen
  end

  factory :feedFetchError do
    sequence(:code)
    message             { "#{code} no message" }

    association :canteen
  end

  factory :feedValidationError do
    sequence(:version)  {|n| n % 2 + 1 }
    sequence(:kind)     {|n| [:invalid_xml, :unknown_version][n % 2] }
    message             { "#{version} no message" }

    association :canteen
  end

  factory :feedUrlUpdatedInfo do
    sequence(:old_url)  {|n| "http://example.org/#{n}.xml" }
  sequence(:new_url)  {|n| "http://example.com/#{n}.xml" }

    association :canteen
  end

  factory :favorite do
    sequence :priority

    association :user
    association :canteen
  end

  factory :parser do
    sequence(:name) {|n| "Parser ##{n}" }

    association :user
  end

  factory :source do
    sequence(:name) {|n| "source##{n}" }

    association :parser
    association :canteen
  end

  factory :feed do
    sequence(:name) {|n| "feed##{n}" }
    sequence(:url) {|n| "example.org/feeds/#{n}.xml" }
    schedule '0 8-14 * * *'

    association :source
  end
end
