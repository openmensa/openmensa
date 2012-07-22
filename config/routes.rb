Openmensa::Application.routes.draw do
  mount Doorkeeper::Engine => '/oauth'

  api_version(module: 'Api::V1', path: 'api/v1', defaults: { format: 'json' }) do
    get '/status', to: 'status#index'
    resources :cafeterias do
      resources :meals do
        resources :comments
      end
    end
  end

  get '/c/:id(/:date)' => 'canteens#show', as: :canteen, constraints: { date: /\d{4}-\d{2}-\d{2}/ }
  resources :canteens, path: 'c'

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
