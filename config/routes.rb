Openmensa::Application.routes.draw do

  match "/auth",                    to: "sessions#new",      as: :login
  match "/auth/signoff",            to: "sessions#destroy",  as: :logout
  match "/auth/:provider",          to: "sessions#failure",  as: :auth
  match "/auth/:provider/callback", to: "sessions#create"
  match "/auth/failure",            to: "sessions#failure",  as: :auth_failure
  match "/auth/register",           to: "sessions#register", as: :register

  match 'oauth/authorize', :to => 'authorization#new'
  post  'oauth/token', :to => proc { |env| Oauth2::TokenEndpoint.new.call(env) }

  get "/static/:id", to: "static#index", as: :static

  namespace :api, defaults: {format: 'json'} do
    get 'status', to: 'status#index'
    resources :users
  end

  # get "/", to: "application#index", as: :application_index
  root to: "static#index"
end
