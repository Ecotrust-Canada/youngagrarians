#
class Location < ActiveRecord::Base
  include Gmaps4rails::ActsAsGmappable
  acts_as_gmappable validation: false

  belongs_to :account, inverse_of: :locations

  has_many :category_tags, dependent: :destroy, foreign_key: 'location_id', inverse_of: :location
  has_many :nested_categories, through: :category_tags

  scope :approved, -> { where( is_approved: true ) } 
  scope :currently_shown, -> { where( 'show_until IS NULL OR show_until > ?', Time.zone.today) }
  scope :surrey, -> {
    where( "city ILIKE '%surrey%' OR province ILIKE '%surrey%' OR street_address ILIKE '%surrey%'" )
  }

  REQUIRED_COLUMNS = %w(id resource_type category subcategories
                        name bioregion street_address city province country postal phone
                        url fb_url twitter_url description email).freeze

  attr_accessor :skip_approval_email
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

  SEARCH_FIELDS = %w(name street_address city province country postal bioregion phone description).freeze
  def self.search(term, _province = nil)
    results = []
    if !term.nil? && !term.empty?
      term = term.downcase
      starts_with = "#{term}%"
      categories = Category.where('LOWER(name) LIKE ?', starts_with).pluck(:id)
      subcategories = Subcategory.where('LOWER(name) LIKE ?', starts_with).pluck(:id)
      if categories
        results += Location.where(is_approved: true).where('category_id IN (?)', categories).all
      end
      if subcategories
        results += Location.joins(:subcategories)
                           .where(is_approved: true)
                           .where('subcategories.id IN (?)', subcategories)
                           .all
      end
      term = "%#{term.tr(' ', '%')}%"

      results += Location.where(is_approved: true)
                         .where(SEARCH_FIELDS.map { |x| "#{x} ILIKE ?" }.join(' OR '), *[term] * SEARCH_FIELDS.length)
                         .all
    end
    results.uniq
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
    format( '%d-%s', id, name.gsub( /[^0-9a-z]+/i, '-' ).sub( /^-/, '' ) )
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
