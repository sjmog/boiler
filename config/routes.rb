require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]
  as :user do
    get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
    put "users" => "devise/registrations#update", :as => "user_registration"
  end
  mount ActionCable.server => "/cable"

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"

    namespace :admin do
      get "dashboard", to: "dashboard#index"
      post "run_scraper", to: "dashboard#run_scraper"
      get "scraper_status", to: "dashboard#scraper_status"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :destroy] do
        member do
          post :restore
          post :validate
        end
        resources :sources, only: [:index], controller: "product_sources"
      end
      resources :product_sources, only: [] do
        member do
          post :approve
          post :disapprove
        end
      end
      get "/admin_status", to: "api#admin_status"
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
