#
class Location < ActiveRecord::Base
  include LocationFieldIds

  LAND_LISTING_PARAMS = %w(land_size cultivable_area zoning
                           current_property_use current_practices
                           surface_description historical_use road_access
                           electricity cell_service long_term_vision hazards
                           residents_present farm_buildings is_fenced tools
                           water_source water_rights onsite_housing
                           restricted_vistor_access agriculture_preferred
                           practices_preferred agronomic_potential soil_details
                           preferred_arrangement mentorship references_required
                           agreement_duration insurance agreement_true ).map( &:to_sym ).freeze
  attr_accessor :primary_category_id, :agreement_true
  include Gmaps4rails::ActsAsGmappable
  include CustomFields
  acts_as_gmappable validation: false

  belongs_to :account, inverse_of: :locations
  belongs_to :person

  has_many :category_tags, dependent: :destroy, foreign_key: 'location_id', inverse_of: :location
  has_many :comments, class_name: 'ListingComment'
  has_many :location_fields
  has_many :nested_categories, through: :category_tags

  scope :approved, -> { where( is_approved: true ) } 
  scope :currently_shown, -> { where( 'show_until IS NULL OR show_until > ?', Time.zone.today) }
  scope :surrey, -> {
    joins( "JOIN category_location_tags ON category_location_tags.location_id = locations.id 
            JOIN nested_categories primaries ON primaries.id = category_location_tags.category_id" ) # assuming provided cats are terminal nodes
    .where( 'primaries.id IN (105, 97) or primaries.parent_category_id IN (105, 97)' )
    #.where( 'primaries.name IN ( ? )', %w(Services\ and\ Suppliers Land\ Listings ) )
  }

  REQUIRED_COLUMNS = %w(id resource_type category subcategories
                        name bioregion street_address city province country postal phone
                        url fb_url twitter_url description email)
  add_boolean_with_comment_field :wooded_land_size
  add_boolean_field :all_true
  add_boolean_with_comment_field :business_plan
  add_boolean_with_comment_field :financial_resources
  add_boolean_with_comment_field :other_financial_resources
  add_boolean_with_comment_field :expansion_options
  add_boolean_with_comment_field :tools
  add_boolean_with_comment_field :is_fenced
  add_boolean_with_comment_field :road_access
  add_boolean_with_comment_field :electricity
  add_boolean_with_comment_field :onsite_housing
  add_boolean_with_comment_field :restricted_vistor_access
  add_boolean_with_comment_field :cell_service
  add_boolean_with_comment_field :farm_buildings
  add_boolean_with_comment_field :water_rights
  add_boolean_with_comment_field :mentorship
  add_boolean_with_comment_field :references_required
  add_boolean_with_comment_field :insurance
  add_boolean_with_comment_field :wooded_area
  add_boolean_with_comment_field :expansion_size
  add_boolean_with_comment_field :owner_resides
  add_boolean_with_comment_field :buildings_required
  add_boolean_with_comment_field :fencing_required
  add_boolean_with_comment_field :tools_required
  add_boolean_with_comment_field :need_housing
  add_number_field :cultivable_area
  add_string_field :zoning
  add_string_field :need_water
  add_string_field :preferred_arrangement
  add_string_field :agronomic_potential
  add_string_field :agreement_duration
  add_string_field :farm_name
  add_string_field :desired_start_date
  add_string_field :fv_region
  add_string_field :desired_total_size
  add_string_field :desired_cultivable_area
  add_string_field :desired_surface_state
  add_string_field :soil_needs
  add_multiselect_field :training
  add_multiselect_field :current_property_use
  add_multiselect_field :desired_use
  add_multiselect_field :desired_practices
  add_multiselect_field :agriculture_preferred
  add_multiselect_field :soil_details
  add_multiselect_field :water_source
  add_multiselect_field :current_practices
  add_multiselect_field :practices_preferred
  add_boolean_with_comment_field :hazards
  add_boolean_with_comment_field :residents_present
  add_text_field :surface_description
  add_text_field :historical_use
  add_text_field :long_term_vision
  attr_accessor :skip_approval_email, :details_complete

  def before_import_save(record)
    if record[:category]
      record[:category].split( /[;,]/ ).each do |category_name|
        c = NestedCategory.find_by( name: category_name )
        nested_categories << c
      end
    end
  end

  # -------------------------------------------------------------- land_listing?
  def land_listing?
    # IDs not consistent migration to migration, hence string matching
    @land_listing ||= begin
      if primary_category_id
        @primary_category ||= NestedCategory.find( primary_category_id )
        return true if @primary_category.name == 'Land Listings' || @primary_category.name == 'Land Listing'
      end
      names = nested_categories.pluck( :name )
      names.include?( 'Land Listings' ) || names.include?( 'Land Listing' )
    end
  end

  # -------------------------------------------------------------- seeker_params
  def self.seeker_params
    r_val = []
    r_val += [:training, :farm_name, :preferred_arrangement, :agreement_duration,
              :desired_start_date, :desired_total_size, :desired_cultivable_area,
              :zoning, :desired_surface_state, :need_water, :all_true, :soil_needs]
    b_with_c = [:string, :boolean]
    [:insurance, :need_housing, :tools_required, :fencing_required,
     :buildings_required, :owner_resides, :business_plan, :financial_resources,
     :other_financial_resources, :wooded_area, :expansion_size].each do |thing|
      r_val << { thing => b_with_c }
    end
    multi = [:value, :comment]
    [:desired_use, :desired_practices, :training].each do |t|
      r_val << { t => multi }
    end
    r_val
  end

  # ---------------------------------------------------------------- land_params
  def self.land_params
    args = Location::LAND_LISTING_PARAMS.dup
    args << :bioregion
    b_with_c = [:string, :boolean]
    [:wooded_land_size, :road_access, :electricity, :cell_service, :hazards,
      :residents_present, :farm_buildings, :tools, :is_fenced, :all_true, :water_rights,
      :onsite_housing, :restricted_vistor_access, :mentorship, :references_required,
      :insurance, :expansion_options ].each do |f|
      args << { f => b_with_c }
    end
    multi = [ :value, :comment ]
    args <<  { current_property_use: multi, practices_preferred: multi, soil_details: multi,
        current_practices: multi, water_source: multi, agriculture_preferred: multi }
  end

  # ------------------------------------------------------------------ is_admin?
  def is_admin?( u )
    u && u == account
  end

  # --------------------------------------------------------------- messageable?
  def messageable?
    email.present? || account
  end

  # ------------------------------------------------------------ seeker_listing?
  def seeker_listing?
    @seeker_listing_check ||= begin
      if primary_category_id
        @primary_category ||= NestedCategory.find( primary_category_id )
        return true if @primary_category.name == 'Farmers Looking for Land'
      end
      nested_categories.pluck( :name ).include?( 'Farmers Looking for Land' )
    end
  end

  # ------------------------------------------------------------------ signature
  def signature( expiry = nil )
    expiry ||= 1.week.since
    params = { id: id, updated_at: updated_at.to_i, expiry: expiry.to_i } 
    key = '8f7e749324d0d0f965d97a9dcfd78973120f970566bf3bbae0aa5bd4000a833b89ccdeb6cb88dfa6e75a206750e60677f9182f73f3d952a40433cdcec16b73e3'
    hmac = OpenSSL::HMAC.digest( OpenSSL::Digest.new( 'sha1' ), key, params.to_json )
    return Base64.urlsafe_encode64( hmac )[0..-2], expiry.to_i
  end
  def skip_approval_email
    @skip_approval_email ||= false
  end

  def visible?
    ( show_until.nil? || show_until > Time.zone.today ) && approved?
  end

  def address_required
    if primary_category_id
      @primary_category ||= NestedCategory.find( primary_category_id )
      return false if @primary_category.name == 'Web Resources'
      return false if @primary_category.name == 'Publications'
    end
    true
  end

  def approved?
    is_approved
  end

  def gmaps4rails_address
    if street_address.present? && postal.present?
      "#{street_address}, #{city}, #{province}, #{country}, #{postal}"
    elsif !postal.present?
      "#{street_address}, #{city}, #{province}, #{country}"
    else
      postal.to_s
    end
  end

  def as_json(_options = nil)
    super include: [:category, :subcategories], except: [:category_id, :is_approved]
  end
  
  # Tells gmaps4rails if it already got the geocoordinates for that or not
  def gmaps
    return true if resource_type == 'Web'
    return false if self[:gmaps] == false # lets us flag entries for re-processing manually
    !(street_address_changed? || city_changed? || country_changed? || postal_changed?)
  end

  # --------------------------------------------------------------------- admin?
  def admin?( user )
    user && user.id == account_id
  end

  # --------------------------------------------------------------- is_approved=
  def is_approved=(value)
    self[:is_approved] = ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
    if value && ( email.present? || account ) && !@skip_approval_email
      UserMailer.listing_approved( self ).deliver_now
    end
  end

  # --------------------------------------------------------------------- to_csv
  def self.to_csv(options = {})
    columns = REQUIRED_COLUMNS
    columns << 'to_delete'
    columns -= ['search', 'category_id', 'subcategories']
    custom_boolean_fields.each do |x|
      columns << ( x.to_s + '_value' )
      columns << x.to_s + '_comments'
    end
    ( custom_number_fields + custom_text_fields + custom_string_fields ).each do |f|
      columns << f.to_s
    end

    CSV.generate(options) do |csv|
      csv << columns
      includes( :nested_categories, :location_fields ).find_each do |location|
        values = location.attributes.dup
        values['category'] = location.nested_categories.map{ |x| x.name }.join( '; ' )
        values['to_delete'] = false
        if location.land_listing? || location.seeker_listing?
          custom_boolean_fields.each do |f|
            if columns.include?( f.to_s + '_value' )
              values[f.to_s + '_value'] = location.send( f.to_s + '_value'  )
              values[f.to_s + '_comments'] = location.send( f.to_s + '_comments'  )
            end
          end
          ( custom_number_fields + custom_text_fields + custom_string_fields ).each do |f|
            if columns.include?( f.to_s )
              values[f.to_s] = location.send( f )
            end
          end
        end
        csv << values.values_at(*columns)
      end
    end
  end
  
  def load_wp_posts
    wp_posts = []
    [self.post_id, self.post2_id].each do |post_id|
      if post_id and post_id =~ /\d+/ 
        require 'rest-client'
        rsp = RestClient.get "http://youngagrarians.org/wp-json/posts/#{ post_id }"
        wp_posts << JSON.parse(rsp.body)
      end
    end
    wp_posts
  end

  # ------------------------------------------------------------------- to_param
  def to_param
    if name.present?
      format( '%d-%s', id, name.gsub( /[^0-9a-z]+/i, '-' ).sub( /^-/, '' ) )
    else
      id.to_s
    end
  end

  # ------------------------------------------------------- land_parameter_names
  def self.land_parameter_names
    @land_parameter_names ||= land_params.map{ |x| x.is_a?( Symbol ) ? x : x.keys }.flatten
  end

  # ------------------------------------------------------- land_parameter_names
  def self.land_seeker_parameter_names
    @land_parameter_names ||= seeker_params.map{ |x| x.is_a?( Symbol ) ? x : x.keys }.flatten
  end
  
  # -------------------------------------------------------- visibible_paramter?
  def visible_parameter?( param_name )
    if land_listing?
      Location.land_parameter_names.include?( param_name.to_sym )
    elsif seeker_listing?
      Location.land_seeker_parameter_names.include?( param_name.to_sym )
    else
      false
    end
  end

  k = self
  rails_admin do

    configure :category_tags do
      visible( false )
    end

    configure :category_id do
      visible( false )
    end

    configure :location_fields do
      visible( false )
    end
    
    configure :comments do
      visible( false )
    end

    ####################################################################
    # RailsAdmin Edit Fields
    ####################################################################
    edit do
      include_all_fields
      field :latitude
      field :longitude
      exclude_fields :created_at, :updated_at, :category, :account

      k.custom_boolean_fields.each do |f|
        field "#{f}_value".to_sym, :boolean do
          visible { bindings[:object].visible_parameter?( f ) }
          label "Has #{f.to_s.humanize}?"
        end
        field "#{f}_comments".to_sym, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_number_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_string_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_text_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      exclude_fields :gmaps
    end

    ####################################################################
    # RailsAdmin List Fields
    ####################################################################
    list do
      field :id
      field :is_approved do
        label 'Approved'
        export_value do
          value == 1 ? 'Yes' : 'No'
        end
        pretty_value do # used in list view columns and show views, defaults to formatted_value for non-association fields
          ( value == 1 ? "<span class='icon-check'></span>" : "<span class='icon-check-empty'></span>" ).html_safe
        end
      end
      field :show_until
      field :name
      field :province
      field :city
      field :street_address
      field :email
      field :resource_type
      field :updated_at
    end

    ####################################################################
    # RailsAdmin Show Fields
    ####################################################################
    show do
      include_all_fields
      field :latitude
      field :longitude
      exclude_fields :created_at, :updated_at, :category, :account

      k.custom_boolean_fields.each do |f|
        field "#{f}_value".to_sym, :boolean do
          visible { bindings[:object].visible_parameter?( f ) }
          label "Has #{f.to_s.humanize}?"
        end
        field "#{f}_comments".to_sym, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_number_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_string_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_text_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
      k.custom_multiselect_fields.each do |f|
        field f, :string do
          visible { bindings[:object].visible_parameter?( f ) }
        end
      end
    end

    ####################################################################
    # RailsAdmin Import Fields
    ####################################################################
    import do
      include_all_fields
      exclude_fields :nested_categories, :category
      k.custom_boolean_fields.each do |f|
        field "#{f}_value".to_sym
        field "#{f}_comments".to_sym
      end
      ( k.custom_text_fields + k.custom_string_fields + k.custom_number_fields ).each do |f|
        field f.to_sym
      end
    end
  end
end
