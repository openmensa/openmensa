Openmensa::Application.routes.draw do
  mount Doorkeeper::Engine => '/oauth'

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :cafeterias, only: [ :index, :show ] do
        resources :meals, only: [ :index ]
      end
    end

    namespace :v2 do
      resources :canteens, only: [ :index, :show ] do
        resources :meals, only: [ :index ]
      end
    end
  end

  get '/c/:id(/:date)' => 'canteens#show', as: :canteen, constraints: { date: /\d{4}-\d{2}-\d{2}/ }
  resources :canteens, path: 'c', only: [ :show ]
  resources :users, path: 'u' do
    resources :favorites, path: 'favs', only: [ :index, :destroy ]
    resources :identities, path: 'ids', only: [ :new, :create, :destroy ]
    resources :canteens, path: 'c', only: [ :index, :new, :create, :edit, :update ]
    resources :messages, path: 'm', only: [ :index ]
  end
  resources :favorites, path: 'favs', only: [ :index ]

  match '/auth',                    to: 'sessions#new',      as: :login
  match '/auth/signoff',            to: 'sessions#destroy',  as: :logout
  match '/auth/:provider',          to: 'sessions#failure',  as: :auth
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/failure',            to: 'sessions#failure',  as: :auth_failure
  match '/auth/register',           to: 'sessions#register', as: :register

  match '/oauth/authorize', :to => 'authorization#new'
  post  '/oauth/token', :to => proc { |env| Oauth2::TokenEndpoint.new.call(env) }

  get '/static/:id', to: 'static#index', as: :static

  # get '/', to: 'application#index', as: :application_index
  root to: 'static#index'
end
