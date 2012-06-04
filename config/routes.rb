Openmensa::Application.routes.draw do

  match "/auth",                    to: "sessions#new",      as: :login
  match "/auth/signoff",            to: "sessions#destroy",  as: :logout
  match "/auth/:provider/callback", to: "sessions#create",   as: :auth, defaults: { provider: 'multipassword' }
  match "/auth/failure",            to: "sessions#failure",  as: :auth_failure
  match "/auth/register",           to: "sessions#register", as: :register

  match 'oauth/authorize', :to => 'authorization#new'
  post  'oauth/token', :to => proc { |env| Oauth2::TokenEndpoint.new.call(env) }

end
