#
class Location < ActiveRecord::Base
  # Field constant definations
  WOODED_LAND_SIZE = 1
  CULTIVABLE_AREA = 2
  ZONING = 3
  CURRENT_PROPERTY_USE = 4
  CURRENT_PRACTICES = 5
  SURFACE_DESCRIPTION = 6
  HISTORICAL_USE = 7
  ROAD_ACCESS = 8
  ELECTRICITY = 9
  CELL_SERVICE = 10
  LONG_TERM_VISION = 10
  HAZARDS = 11
  RESIDENTS_PRESENT = 12
  FARM_BUILDINGS = 13
  IS_FENCED = 14
  TOOLS = 15
  WATER_SOURCE = 16
  WATER_RIGHTS = 17
  ONSITE_HOUSING = 18
  RESTRICTED_VISTOR_ACCESS = 19
  AGRICULTURE_PREFERRED = 20
  PRACTICES_PREFERRED = 21
  AGRONOMIC_POTENTIAL = 22
  SOIL_DETAILS = 23
  PREFERRED_ARRANGEMENT = 24
  MENTORSHIP = 25
  REFERENCES_REQUIRED = 26
  AGREEMENT_DURATION = 27
  INSURANCE = 28
  AGREEMENT_TRUE = 29
  EXPANSION_OPTIONS = 30
  TRAINING = 31
  BUSINESS_PLAN = 32
  FINANCIAL_RESOURCES = 33
  OTHER_FINANCIAL_RESOURCES = 34
  FARM_NAME = 35
  DESIRED_START_DATE = 36
  FV_REGION = 37
  DESIRED_TOTAL_SIZE = 38
  WOODED_AREA = 39
  DESIRED_CULTIVABLE_AREA = 40
  EXPANSION_SIZE = 41
  DESIRED_SURFACE_STATE = 42
  OWNER_RESIDES = 43
  BUILDINGS_REQUIRED = 44
  FENCING_REQUIRED = 45
  TOOLS_REQUIRED = 46
  NEED_WATER = 47
  NEED_HOUSING = 48
  DESIRED_USE = 49
  DESIRED_PRACTICES = 50
  SOIL_NEEDS = 51

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
    where( "city ILIKE '%surrey%' OR province ILIKE '%surrey%' OR street_address ILIKE '%surrey%'" )
  }

  REQUIRED_COLUMNS = %w(id resource_type category subcategories
                        name bioregion street_address city province country postal phone
                        url fb_url twitter_url description email)
  add_boolean_with_comment_field :wooded_land_size
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
  add_boolean_with_comment_field :need_water
  add_boolean_with_comment_field :need_housing
  add_number_field :cultivable_area
  add_string_field :zoning
  add_string_field :training
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

  # -------------------------------------------------------------- land_listing?
  def land_listing?
    # IDs not consistent migration to migration, hence string matching
    if primary_category_id
      @primary_category ||= NestedCategory.find( primary_category_id )
      return true if @primary_category.name == 'Land Listings' || @primary_category.name == 'Land Listing'
    end
    names = nested_categories.pluck( :name )
    names.include?( 'Land Listings' ) || names.include?( 'Land Listing' )
  end
  # -------------------------------------------------------------- seeker_params
  def self.seeker_params
    r_val = []
    r_val += [ :training, :farm_name, :preferred_arrangement, :agreement_duration,
               :desired_start_date, :desired_total_size, :desired_cultivable_area,
               :zoning, :desired_surface_state ]
    b_with_c = [:string, :boolean]
    [ :insurance, :need_housing, :need_water, :tools_required, :fencing_required,
      :buildings_required, :owner_resides, :business_plan, :financial_resources,
      :other_financial_resources, :wooded_area, :expansion_size].each do |thing|
      r_val << { thing => b_with_c }
    end
    multi = [ :value, :comment ]
    [:desired_use, :desired_practices, :soil_needs ].each do |t|
      r_val << { t => multi }
    end
    return r_val
  end
  # ---------------------------------------------------------------- land_params
  def self.land_params
    args = Location::LAND_LISTING_PARAMS.dup
    args << :bioregion
    b_with_c = [:string, :boolean]
    [:wooded_land_size, :road_access, :electricity, :cell_service, :hazards,
      :residents_present, :farm_buildings, :tools, :is_fenced, :water_rights,
      :onsite_housing, :restricted_vistor_access, :mentorship, :references_required,
      :insurance, :expansion_options ].each do |f|
      args << { f => b_with_c }
    end
    multi = [ :value, :comment ]
    args <<  { current_property_use: multi, practices_preferred: multi, soil_details: multi,
        current_practices: multi, water_source: multi, agriculture_preferred: multi }
  end

  # --------------------------------------------------------------- messageable?
  def messageable?
    email.present? || account
  end

  # ------------------------------------------------------------ seeker_listing?
  def seeker_listing?
    if primary_category_id
      @primary_category ||= NestedCategory.find( primary_category_id )
      return true if @primary_category.name == 'Farmers Looking for Land'
    end
    nested_categories.pluck( :name ).include?( 'Farmers Looking for Land' )
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
  
  # dead code?
  # SEARCH_FIELDS = %w(name street_address city province country postal bioregion phone).freeze
  # def self.search(term, _province = nil)
  #   results = []
  #   if !term.nil? && !term.empty?
  #     term = term.downcase
  #     starts_with = "#{term}%"
  #     categories = Category.where('LOWER(name) LIKE ?', starts_with).pluck(:id)
  #     subcategories = Subcategory.where('LOWER(name) LIKE ?', starts_with).pluck(:id)

  #     if categories
  #       results += Location.where(is_approved: true)
  #                          .where('category_id IN (?)', categories).select("name, street_address, city, province, country, categories")
  #     end
  #     if subcategories
  #       results += Location.joins(:subcategories)
  #                          .where(is_approved: true)
  #                          .where('subcategories.id IN (?)', subcategories).select("name, street_address, city, province, country, categories")
  #     end
  #     term = "%#{term.tr(' ', '%')}%"

  #     results += Location.where(is_approved: true)
  #                        .where(SEARCH_FIELDS.map { |x| "#{x} ILIKE ?" }.join(' OR '), *[term] * SEARCH_FIELDS.length)
  #                        .select("name, street_address, city, province, country, categories")
  #   end
  #   results.uniq
  # end

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

  def is_approved=(value)
    self[:is_approved] = ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
    if value && ( email.present? || account ) && !@skip_approval_email
      UserMailer.listing_approved( self ).deliver_now
    end
  end

  def self.to_csv(options = {})
    columns = REQUIRED_COLUMNS | column_names.reject { |c| c == 'category_id' } | ['to_delete']

    CSV.generate(options) do |csv|
      csv << columns
      all.find_each do |location|
        values = location.attributes.dup
        values['category'] = location.category.name
        values['subcategories'] = location.subcategories.map(&:name).join(';')
        values['to_delete'] = false
        csv << values.values_at(*columns)
      end
    end
  end
  
  def to_param
    if name.present?
      format( '%d-%s', id, name.gsub( /[^0-9a-z]+/i, '-' ).sub( /^-/, '' ) )
    else
      id.to_s
    end
  end

  def self.import(file)
    line_num = 2
    CSV.foreach(file.path, headers: true) do |row|
      location = find_by_id(row['id']) || new
      location.skip_approval_email = true
      if location && row['to_delete'].present? && row['to_delete'].casecmp('true').zero?
        location.destroy
      else
        location.attributes = row.to_hash.slice(*accessible_attributes)
        location.is_approved = true unless row['is_approved'].present?
        category = Category.find_by_name(row['category'])
        if category
          location.category = category
        else
          raise "Category \"#{row['category']}\" not found. Line #{line_num} Record: #{location.inspect}"
        end

        row['subcategories'].present? && row['subcategories'].split(';').each do |s|
          location.subcategories = []
          subcategory = Subcategory.find_by_name(s.strip)
          if subcategory
            location.subcategories << subcategory
          else
            raise "Subcategory \"#{s.strip}\" not found. Line #{line_num} Record: #{location.inspect}"
          end
        end
        location.save!

        line_num += 1
      end
    end
  end

  rails_admin do
    configure :category_tags do
      visible( false )
    end
    configure :category do
      visible( false )
    end

    configure :nestered_categories do
      visible( false )
    end

    list do
      field :name
      field :street_address
      field :city
      field :bioregion
      field :province
      field :is_approved
      field :country
      field :postal
      field :nested_category
      field :email
      field :resource_type
      field :gmaps
      field :created_at
      field :updated_at
    end
  end
end
