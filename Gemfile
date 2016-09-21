source 'https://rubygems.org'
ruby '2.2.5'

gem 'rails', '~> 4.2.0'
gem 'rake'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'mysql2'
gem 'ejs'
# Gems used only for assets and not required
# in production environments by default.
gem 'thin'

gem 'sass-rails'
gem 'coffee-rails'
# Add Foundation Here
gem 'compass-rails' # you need this or you get an err
#gem 'foundation-rails'
gem 'font-awesome-rails'
gem 'bootstrap-sass'
gem 'eco'
gem 'exception_notification'
gem 'marionette-rails'
gem 'haml'
gem 'jbuilder'
gem 'sass'
gem 'uglifier'

gem 'premailer-rails'
gem 'nokogiri'
gem 'rest-client'

gem 'modernizr-rails'

# like bower.json...
#source 'https://rails-assets.org' do
  #gem 'rails-assets-leaflet', '~> 0.7.7'
  #gem 'rails-assets-leaflet.markercluster' #: "leaflet.markerclusterer#^0.5.0",
  #gem 'rails-assets-riot', '~> 2.3.18'
  #gem 'rails-assets-riot-mui'
#end

#gem 'riotjs-rails', '~> 2.3.18'
#gem 'leaflet-rails', '~> 0.7.7'
#gem 'leaflet-markercluster-rails'


gem 'gmaps4rails', '< 2.0.0'
gem 'geocoder'

gem 'jquery-rails'
gem 'spreadsheet', '~> 0.8.3'
#gem 'bcrypt-ruby', '~> 3.0.0'
#gem 'warden', '~> 1.2.1'
gem 'rails_admin'
gem 'rails_admin_import' # this looks to have some backported , git: 'git://github.com/yagudaev/rails_admin_import.git'

gem 'webshims-rails'

group :development, :test do
  gem 'rb-readline',	'~> 0.4.2'
  gem 'quiet_assets'

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'randexp',              '~> 0.1.7'
  gem 'awesome_print',        '~> 1.0.2'
  gem 'table_print',          '~> 1.0.0'
  gem 'pry'
  gem 'letter_opener'

  # Guard, guard!
  gem 'guard',                '~> 1.3.2'
  gem 'guard-rspec',          '~> 1.2.1'
  gem 'guard-spin',           '~> 0.3.0'
  gem 'guard-coffeescript',   '~> 1.2.0'
  gem 'rb-fsevent',           '~> 0.9.1'

  # Javascript Testing
  gem 'jasmine',              '~> 1.2.1'

  # Docs
  gem 'yard', '~> 0.8.5.2'
end

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  #gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'email_spec',           '~> 1.2.1'
  gem 'factory_girl_rails'
  gem 'cucumber-rails', require: false
  gem 'mocha', require: false

  gem 'launchy'
  gem 'webmock'
  gem 'timecop'
  gem 'test-unit'
  gem 'sqlite3'
end
group :production, :development, :staging do
  gem 'rails_12factor'
end

gem 'devise'
gem 'safe_yaml' #, '0.6.3'

