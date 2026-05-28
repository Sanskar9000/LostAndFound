Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  devise_for :admin_users, ActiveAdmin::Devise.config
  # get 'claims/new'
  # get 'claims/create'
  # get 'claims/index'
  # get 'claims/show'
  # get 'items/index'
  # get 'items/show'
  # get 'items/new'
  # get 'items/create'
  # get 'dashboard/index'
  
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  ActiveAdmin.routes(self)

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root "dashboard#index"
  resource :profile, only: [:show, :edit, :update]
  get "/search", to: "search#index", as: :search
  get "/analytics", to: "analytics#index", as: :analytics
  resources :notifications, only: [:index, :new, :create, :update] do
    collection do
      patch :mark_all_read
    end
  end

  resources :items do
    resource :conversation, only: [:create], controller: "item_conversations"
    resources :claims, only: [:new, :create]
    member do
      patch :mark_recovered
    end
  end

  resources :conversations, only: [:index, :show] do
    resources :messages, only: [:create]
  end

  resources :claims, only: [:index, :show]
  resources :staff_claims, only: [:index]
  get "/staff/claims/:id", to: "staff_claims#show", as: :staff_claim
  put "/staff/claims/:id/approve", to: "staff_claims#approve", as: :approve_staff_claim
  put "/staff/claims/:id/reject",  to: "staff_claims#reject",  as: :reject_staff_claim
  patch "/staff/claims/:id/verify_pickup", to: "staff_claims#verify_pickup", as: :verify_pickup_staff_claim
  get "/pickup/:token", to: "pickup_verifications#show", as: :pickup_verification
  patch "/pickup/:token", to: "pickup_verifications#update", as: :complete_pickup_verification

  get "/verification/pending", to: "verification#pending", as: :verification_pending
end
