Rails.application.routes.draw do

  post '/rate' => 'rater#create', :as => 'rate'
  devise_for :admins, path: "admin",
    controllers: {sessions: "admin/sessions"}
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}

  root "static_pages#home"
  mount ActionCable.server => "/cable"
  namespace :admin do
    root "home#index", path: "/"
    resources :orders, only: [:index, :show, :destroy]
    resources :shop_requests, only: [:index, :update]
    resources :categories
    resources :users
    resources :shops, except: [:new, :create, :show]
  end

  namespace :dashboard do
    root "statistics#index", path: "/"
    resources :shops do
      get :update_multiple, on: :member
      resources :products
      resources :orders
      resources :shop_managers, only: [:index, :create, :destroy]
      resources :order_managers, only: :index
      resources :order_products
    end
    resources :statistics
  end

  resources :shops, only: [:index, :show]
  resources :products, only: [:index, :show, :new] do
    resources :comments, only: :create
  end
  resources :comments, only: :destroy
  resources :carts
  resources :orders
  resource :orders
  resources :users, only: :show
  resources :events, only: [:index]
  resource  :events, only: [:update]
  resources :categories do
    resources :products
  end
  resources :tags, only: :show
  get "search(/:search)", to: "searches#index", as: :search
end
