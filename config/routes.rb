Openmensa::Application.routes.draw do

  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      resources :canteens, only: [ :index, :show ] do
        resources :days, only: [ :index, :show ] do
          resources :meals, only: [ :index, :show ]
        end
        get 'meals' => 'meals#canteen_meals'
      end
    end
  end

  get '/c/:id(/:date)' => 'canteens#show', as: :canteen, constraints: { date: /\d{4}-\d{2}-\d{2}/ }
  get '/c/:id/fetch' => 'canteens#fetch', as: :fetch_canteen
  resources :canteens, path: 'c', only: [ :show ] do
    resource :favorite, only: [ :create, :destroy ]
  end
  resources :users, path: 'u' do
    resources :favorites, path: 'favs', only: [ :index ]
    resources :identities, path: 'ids', only: [ :new, :create, :destroy ]
    resources :canteens, path: 'c', only: [ :index, :new, :create, :edit, :update ] do
      resources :messages, path: 'm', only: [ :index ]
    end
    get 'm', to: 'messages#overview', as: :messages
  end
  resources :favorites, path: 'favs', only: [ :index ]

  get '/auth',                    to: 'sessions#new',      as: :login
  get '/auth/signoff',            to: 'sessions#destroy',  as: :logout
  get '/auth/:provider',          to: 'sessions#failure',  as: :auth
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure',            to: 'sessions#failure',  as: :auth_failure
  get '/auth/register',           to: 'sessions#register', as: :register

  get '/impressum', to: 'static#impressum', as: :imprint

  # get '/', to: 'application#index', as: :application_index
  root to: 'static#index'
end
