Youngagrarians::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount RailsAdminImport::Engine => '/rails_admin_import', as: 'rails_admin_import'

  resources :categories
  resources :subcategories, only: [:index]

  get 'locations/filtered/:filtered' => 'locations#index', as: :locations_filtered
  resources :locations
  get 'surrey.json', controller: 'locations', action: 'index', format: 'json', surrey: 1

  get 'home/index'
  get 'map', controller: 'home', action: 'map'
  root to: 'home#index'

  # Authentication flow
  get  '/login'                => 'accounts#login',              as: :login
  post '/login'                => 'accounts#login_post',         :as => :login_post
  post '/login.json'           => 'accounts#login_post',         :as => :login_post_json, :format => 'json'
  get  '/logout'               => 'accounts#logout',             :as => :logout
  get  '/create_account'               => 'accounts#new',                :as => :signup
  post '/create_account'               => 'accounts#create',             :as => :create_account
  get  '/forgot_password'      => 'accounts#forgot_password',    as: :forgot_password
  post '/forgot_password'      => 'accounts#retrieve_password',  :as => :retrieve_password
  get  '/password_sent'        => 'accounts#password_sent',      :as => :password_sent
  get  '/password_reset/:code' => 'accounts#password_reset',     :as => :password_reset
  put  '/password_reset/:code' => 'accounts#reset_password',     :as => :reset_password

  get  '/verify_credentials'   => 'accounts#verify_credentials', :as => :verify_credentials
  get 'surrey.json', controller: 'locations', action: 'index', city: 'surrey'

  post '/search' => 'locations#search', :as => :search
  get 'sitemap.xml', controller: 'home', action: 'sitemap', format: 'xml'
end
