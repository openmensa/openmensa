
FactoryGirl.define do

  factory :user do
    sequence(:login) { |n| "user#{n}" }
    email            { "#{login}@example.org" }
    name               'John Doe'

    after(:create) do |user|
      FactoryGirl.create(:identity, user: user)
    end
  end

  factory :admin, parent: :user do
    admin true
  end

  factory :developer, parent: :user do
    developer true
  end

  factory :identity do
    association :user

    sequence(:uid) { |n| n.to_s.hash.to_s.gsub(/\D/, '') }
    provider         'twitter'
    token            'apiTocken'
  end

  factory :application, class: 'Doorkeeper::Application' do
    sequence(:name)         { |n| "OAuth2 Client ##{n}" }
    sequence(:redirect_uri) { |n| "http://test.host/c#{n}/cb" }
  end

  factory :canteen do
    sequence(:name) { |n| "Mensa ##{n}"}
    address         "Marble Street, 12345 City"
    url             "http://example.com/canteen_feed.xml"

    association :user
  end

  factory :meal do
    sequence(:category) { |n| "Meal ##{n}" }
    name                { "The name of #{category}." }
    date                { Time.zone.now }

    association :canteen
  end
end
