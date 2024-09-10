require "sidekiq/web"
require "sidekiq-status/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
                       omniauth_callbacks: "users/omniauth_callbacks",
                       registrations: "users/registrations",
                     }, skip: [:sessions, :registrations]

  devise_scope :user do
    get "authenticate", to: "users/registrations#new_or_sign_in", as: :new_user_session
    get "authenticate", to: "users/registrations#new_or_sign_in", as: :new_user_registration
    post "sign_in", to: "devise/sessions#create", as: :user_session
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
    post "sign_up", to: "users/registrations#create", as: :user_registration
  end

  mount ActionCable.server => "/cable"

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => "/sidekiq"
    mount PgHero::Engine, at: "pghero"
  end

  namespace :api do
    namespace :v1 do
      get "current_user", to: "users#current"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "pages#home"

  # React Router handles routing for non-admin, non-API routes
  get "*path", to: "app#index", constraints: lambda { |req|
             !req.xhr? && req.format.html?
           }
end
