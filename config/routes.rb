Rails.application.routes.draw do
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
  
  devise_for :users
  ActiveAdmin.routes(self)

  root "dashboard#index"

  resources :items do
    resources :claims, only: [:new, :create]
  end

  resources :claims, only: [:index, :show]
  resources :staff_claims, only: [:index]
  get "/staff/claims/:id", to: "staff_claims#show", as: :staff_claim
  put "/staff/claims/:id/approve", to: "staff_claims#approve", as: :approve_staff_claim
  put "/staff/claims/:id/reject",  to: "staff_claims#reject",  as: :reject_staff_claim

  get "/verification/pending", to: "verification#pending", as: :verification_pending
end