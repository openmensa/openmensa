
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

  factory :identity do
    association :user

    sequence(:uid) { |n| n.to_s.hash.to_s.gsub(/\D/, '') }
    provider         'twitter'
    token            'apiTocken'
  end

  factory :access_token, class: 'Oauth2::AccessToken' do
    association :user
    association :client
    # association :refresh_token
  end

  factory :client, class: 'Oauth2::Client' do
    association :user
    sequence(:name)         { |n| "OAuth2 Client ##{n}" }
    sequence(:redirect_uri) { |n| "http://application/c#{n}/cb" }

    website "http://example.com"
  end

  factory :trusted_client, parent: :client do
    trusted true
  end

  factory :refresh_token, class: 'Oauth2::RefreshToken' do
    association :client
  end

  factory :cafeteria do
    sequence(:name) { |n| "Mensa ##{n}"}
    address         "Marble Street, 12345 City"
    url             "http://example.com/m1.xml"

    association :user
  end

  factory :meal do
    sequence(:category) { |n| "Meal ##{n}" }
    name                { "The name of #{category}." }
    date                { Time.zone.now }

    association :cafeteria
  end
end
