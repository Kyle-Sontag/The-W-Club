Rails.application.routes.draw do
  devise_for :users

  root "products#index"

  namespace :admin do
    resources :products
    resources :categories
  end

  resources :categories, only: [ :show ]
  resources :products, only: [ :show ]
end
