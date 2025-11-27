Rails.application.routes.draw do
  root "products#index"

  namespace :admin do
    resources :products
    resources :categories
  end

  resources :categories, only: [ :show ]
  resources :products, only: [ :show ]
end
