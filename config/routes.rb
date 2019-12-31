# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v2 do
      resources :canteens, only: [:index, :show] do
        resources :days, only: [:index, :show] do
          resources :meals, only: [:index, :show]
        end
        get 'meals' => 'meals#canteen_meals'
      end
    end
  end

  resources :canteens, path: 'c', only: [:new, :create]
  get '/wanted' => 'canteens#wanted', as: :wanted_canteens
  get '/c/:id(/:date)' => 'canteens#show', as: :canteen, constraints: {date: /\d{4}-\d{2}-\d{2}/}
  resources :canteens, path: 'c', only: [:show, :new, :create, :edit, :update] do
    resource :favorite, only: [:create, :destroy]
    resource :active, controller: :canteen_activation, only: [:create, :destroy]
    resources :data_proposals, path: 'proposals', only: [:new, :create, :index]
    resources :feedbacks, only: [:new, :create, :index]
    resources :messages, path: 'm', only: [:index]
  end
  resources :users, path: 'u' do
    resources :favorites, path: 'favs', only: [:index]
    resources :identities, path: 'ids', only: [:new, :create, :destroy]
    resource :developer
  end
  get 'activate/:token', to: 'developers#activate', as: :activate

  resources :favorites, path: 'favs', only: [:index]
  resources :sources, only: [:create, :update, :edit] do
    resources :feeds, only: [:create]
  end
  get '/feeds/:id/fetch' => 'feeds#fetch', as: :feed_fetch
  get '/feeds/:id/messages' => 'feeds#messages', as: :feed_messages
  resources :feeds, only: [:update, :destroy]
  resources :parsers do
    resources :sources, only: [:new, :create]
  end
  post '/parsers/:id/sync', to: 'parsers#sync', as: :sync_parser
  post '/sources/:id/sync', to: 'sources#sync', as: :sync_source
  get '/sources/:id/messages' => 'sources#messages', as: :source_messages

  get '/auth',                    to: 'sessions#new',      as: :login
  get '/auth/signoff',            to: 'sessions#destroy',  as: :logout
  get '/auth/:provider',          to: 'sessions#failure',  as: :auth
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/failure',            to: 'sessions#failure',  as: :auth_failure
  get '/auth/register',           to: 'sessions#register', as: :register

  get '/impressum', to: 'static#impressum', as: :imprint
  get '/about', to: 'static#about', as: :about
  get '/support', to: 'static#support', as: :support
  get '/contribute', to: 'static#contribute', as: :contribute

  get '/menu(/:date)' => 'menu#show', as: :menu, constraints: {date: /\d{4}-\d{2}-\d{2}/}

  # get '/', to: 'application#index', as: :application_index
  root to: 'static#index'
end
