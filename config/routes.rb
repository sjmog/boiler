require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
                       omniauth_callbacks: "users/omniauth_callbacks",
                       registrations: "users/registrations",
                     }, skip: [:sessions, :registrations]

  devise_scope :user do
    get "sign_in", to: "users/registrations#new_or_sign_in", as: :new_user_session
    get "sign_up", to: "users/registrations#new_or_sign_in", as: :new_user_registration
    post "sign_in", to: "devise/sessions#create", as: :user_session
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
    post "sign_up", to: "users/registrations#create", as: :user_registration
  end

  mount ActionCable.server => "/cable"

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  namespace :api do
    namespace :v1 do
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "pages#home"
end
