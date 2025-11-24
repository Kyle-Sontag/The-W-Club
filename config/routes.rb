Rails.application.routes.draw do
  get "categories/show"
  root "products#index"

  resources :categories, only: [ :show ]
  resources :products, only: [ :show ]
end
