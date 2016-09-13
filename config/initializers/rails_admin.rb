# RailsAdmin config file. Generated on January 03, 2014 17:13
# See github.com/sferik/rails_admin for more informations

require Rails.root.join('lib/rails_admin_approve_resource')
require Rails.root.join('lib/rails_admin_unapprove_resource')
require Rails.root.join('lib/rails_admin_export')
require Rails.root.join('lib/rails_admin_show_in_app')
require Rails.root.join('lib/rails_admin_multifield')

RailsAdmin::Config::Fields::Types::register(:multifield, RailsAdmin::Config::Fields::Types::MultiField)

RailsAdmin.config do |config|
  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = %w(Youngagrarians Admin)
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize,
  # controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_admin_user } # auto-generated
  config.authorize_with do
    redirect_to main_app.admin_login_path if current_admin_user.nil?
  end

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  config.excluded_models = ['Category', 'Subcategory', 'LocationField', 'CategoryTag' ]

  # Include specific models (exclude the others):
  # config.included_models = ['Category', 'Location', 'Subcategory']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]

  config.actions do
    # root actions
    dashboard # mandatory
    # collection actions
    index # mandatory
    approve_resource do
      visible do
        bindings[:abstract_model].model.to_s == 'Location'
      end
    end
    unapprove_resource do
      visible do
        bindings[:abstract_model].model.to_s == 'Location'
      end
    end
    export do
      visible do
        bindings[:abstract_model].model.to_s == 'Location'
      end
    end
    import do
      visible do
        bindings[:abstract_model].model.to_s == 'Location'
      end
    end
    history_index
    bulk_delete
    # member actions
    show
    edit do
      visible do
        bindings[:abstract_model].model.to_s != 'Account'
      end
    end
    new do
      visible do
        bindings[:abstract_model].model.to_s != 'Account'
      end
    end    
    delete
    # history_show
    show_in_app do
      visible do
        bindings[:abstract_model].model.to_s == 'Location'
      end
    end

    # Set the custom action here
  end

  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application)
  #     but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified),
  #     which may smooth your RailsAdmin development workflow.

  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:

  ###  Category  ###

  # config.model 'Category' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your category.rb model definition

  #   # Found associations:

  #     configure :locations, :has_many_association
  #     configure :subcategories, :has_many_association

  #   # Found columns:

  #     configure :id, :integer
  #     configure :name, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below.
  #                                     # OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases
  #     # (resp. when creating, updating, modifying from another model in a
  #     # popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section
  #     # with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

  ###  Location  ###
  #config.model 'NestedCategory' do
  #  config.name :name
  #end

  # config.model 'Location' do
  #   # You can copy this to a 'rails_admin do ... end' block inside your location.rb model definition

  #   # Found associations:

  #   # configure :category, :belongs_to_association
  #   # configure :subcategories, :has_and_belongs_to_many_association
  #   configure :category_tags, :has_many_association

  #   # Found columns:

  #   configure :id, :integer
  #   configure :latitude, :float
  #   configure :longitude, :float
  #   configure :gmaps, :boolean
  #   configure :street_address, :string
  #   configure :name, :string
  #   configure :content, :text
  #   configure :bioregion, :string
  #   configure :phone, :string
  #   configure :url, :string
  #   configure :fb_url, :string
  #   configure :twitter_url, :string
  #   configure :description, :text
  #   configure :is_approved, :boolean
  #   #configure :created_at, :datetime
  #   #configure :updated_at, :datetime
  #   configure :category_id, :integer # Hidden
  #   configure :resource_type, :string
  #   configure :email, :string
  #   configure :postal, :string
  #   configure :show_until, :date
  #   configure :city, :string
  #   configure :country, :string
  #   configure :province, :string

  #   attr_accessible :gmaps

  #   # Cross-section configuration:

  #   # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   # label_plural 'My models'      # Same, plural
  #   # weight 0                      # Navigation priority. Bigger is higher.
  #   # parent OtherModel             # Set parent model for navigation. MyModel
  #   #                               # will be nested below. OtherModel will be on first position of the dropdown
  #   # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #   list do
  #     # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     # items_per_page 100    # Override default_items_per_page
  #     # sort_by :id           # Sort column (default is primary key)
  #     # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #   end
  #   show { ; }
  #   edit { ; }
  #   export do
  #     field :subcategories do
  #       bindings[:object].subcategories.map(&:name).join(';')
  #     end

  #     field :category do
  #       bindings[:object].category.name
  #     end

  #     field :to_delete do
  #       export_value do
  #         false
  #       end
  #     end
  #   end
  #   import
  #   # also see the create, update, modal and nested sections, which override
  #   # edit in specific cases (resp. when creating, updating, modifying from
  #   # another model in a popup modal or modifying from another model nested form)
  #   # you can override a cross-section field configuration in any section with
  #   # the same syntax `configure :field_name do ... end`
  #   # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

  config.configure_with(:import) do |import_config|
    import_config.logging = true
  end

 # config.model 'Location' do
 #   import do 
 #     excluded_fields do
 #       [:category_id]
 #     end
 #     label :name
 #   end
 # end
end

