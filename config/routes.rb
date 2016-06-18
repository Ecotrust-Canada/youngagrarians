Youngagrarians::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount RailsAdminImport::Engine => '/rails_admin_import', as: 'rails_admin_import'

  resources :categories
  resources :subcategories, only: [:index]
  
  # [cvo] Surrey probably doesn't need their own json url, since if the user navigates out of surrey we still want locations showing up.
  get 'surrey.json', controller: 'locations', action: 'index', format: 'json', surrey: 1
  get 'locations/filtered/:filtered' => 'locations#index', as: :locations_filtered
  get 'signup' => 'accounts#new'
  resources :locations do
    resource :message
    resources :comments, only: [:create, :destroy]
  end

  get 'home/index'
  get 'map', controller: 'home', action: 'map', as: 'map'
  get 'embed', controller: 'home', action: 'map', as: 'embed-map'
  get 'splash', controller: 'home', action: 'splash', as: 'splash'
  root to: 'home#index'

  # Authentication flow
  #get  '/login'                => 'accounts#login',              as: :login
  post '/login'                => 'accounts#login_post',         :as => :login_post
  post '/login.json'           => 'accounts#login_post',         :as => :login_post_json, :format => 'json'
  get  '/logout'               => 'sessions#destroy'
  post '/create_account'               => 'accounts#create',             :as => :create_account
  get  '/password_sent'        => 'accounts#password_sent',      :as => :password_sent

  get  '/verify_credentials'   => 'accounts#verify_credentials', :as => :verify_credentials

  resources :password_resets


  post '/search' => 'locations#search', :as => :search
  get '/category/:top_level_name', as: 'top_level_category', controller: 'categories', action: 'show'
  get '/category/:top_level_name', as: 'meta_category', controller: 'categories', action: 'show'
  get '/category/:top_level_name/:subcategory_name', as: 'subcategory', controller: 'categories', action: 'show'
  resources :accounts do
    resource :message
  end
  resource :session
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  get 'thanks' => 'locations#thanks'
  get 'sitemap.xml', controller: 'home', action: 'sitemap', format: 'xml'
  get 'new-listing', controller: 'locations', action: 'new', as: 'new_listing'
end
