Rails.application.routes.draw do
  devise_for :users

  root "products#index"

  namespace :admin do
    resources :products
    resources :categories
  end

  resource :cart, only: [ :show ]
  resources :cart_items, only: [ :create, :update, :destroy ]
  resources :addresses
  resources :orders, only: [ :new, :create, :show, :index ]

  get "search", to: "products#search", as: "search"
  get "sale", to: "categories#sale", as: "sale"
  resources :categories, only: [ :show ]
  resources :products, only: [ :show ]
end
