Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :notifications, only: [:index, :show, :update]
  # Devise routes for authentication
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # Root path
  root 'home#index'

  # RESTful routes
  resources :jobs do
    member do
      patch :apply
      patch :accept
      patch :reject
      patch :complete
    end
    collection do
      get :urgent
      get :my_applications
    end
  end

  resources :hospitals do
    member do
      get :dashboard
    end
    resources :jobs, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :matchings, only: [:index, :show, :update] do
    member do
      patch :accept
      patch :reject
      patch :cancel
      patch :complete
    end
  end

  resources :profiles, only: [:new, :create, :show, :edit, :update] do
    collection do
      patch :toggle_availability
    end
  end

  resources :reviews, only: [:create, :show, :edit, :update]

  # User dashboard routes
  get '/dashboard', to: 'users#dashboard'
  get '/my_jobs', to: 'users#my_jobs'
  get '/my_applications', to: 'users#my_applications'
  get '/my_hospital', to: 'users#my_hospital'

  # API routes for mobile app (future)
  namespace :api do
    namespace :v1 do
      resources :jobs, only: [:index, :show]
      resources :matchings, only: [:create, :update]
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
