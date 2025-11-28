Rails.application.routes.draw do
  devise_for :users

  root "products#index"

  namespace :admin do
    resources :products
    resources :categories
  end

  get "search", to: "products#search", as: "search"
  get "sale", to: "categories#sale", as: "sale"
  resources :categories, only: [ :show ]
  resources :products, only: [ :show ]
end
