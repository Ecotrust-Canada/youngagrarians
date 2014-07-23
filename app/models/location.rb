class Location < ActiveRecord::Base
  include Gmaps4rails::ActsAsGmappable
  acts_as_gmappable :validation => false

  belongs_to :category
  has_and_belongs_to_many :subcategories

  # TODO: security issue, need to not allow is_approved to be sset by just anybody.
  attr_accessible :latitude, :longitude, :name, :content, :bioregion, :phone, :url, :fb_url,
                  :twitter_url, :description, :is_approved, :category_id, :resource_type, :email, :postal, :show_until,
                  :street_address, :city, :country, :province, :gmaps, :subcategory_ids

  REQUIRED_COLUMNS = ['id', 'resource_type', 'category', 'subcategories',
      'name', 'bioregion', 'street_address', 'city', 'province', 'country', 'postal', 'phone', 
      'url', 'fb_url', 'twitter_url', 'description', 'email']

  attr_accessor :skip_approval_email

  validates_presence_of :category

  def skip_approval_email
    @skip_approval_email ||= false
  end

  def gmaps4rails_address
    if street_address.present? && postal.present?
      "#{street_address}, #{city}, #{province}, #{country}, #{postal}"
    elsif !postal.present?
      "#{street_address}, #{city}, #{province}, #{country}"
    else
      "#{postal}"
    end
  end

  def as_json(options = nil)
    super :include => [ :category, :subcategories ], :except => [ :category_id, :is_approved ]
  end

  def self.search(term, province = nil)
    results = []
    if not term.nil? and not term.empty?
      term = term.downcase
      starts_with = "#{term}%"
      categories = Category.where('LOWER(name) LIKE ?', starts_with).pluck(:id)
      subcategories = Subcategory.where('LOWER(name) LIKE ?', starts_with).pluck(:id)
      if categories
        results += Location.where(:is_approved => true).where('category_id IN (?)', categories).all
      end
      if subcategories
        results += Location.joins(:subcategories).where(:is_approved => true).where('subcategories.id IN (?)', subcategories).all
      end
      term = "%#{term.gsub(' ', '%')}%"
      results += Location.where(:is_approved => true)
        .where("LOWER(name) LIKE ? OR LOWER(street_address) LIKE ? OR LOWER(city) LIKE ? OR LOWER(province) LIKE ? or LOWER(country) LIKE ? OR LOWER(postal) LIKE ? OR LOWER(bioregion) LIKE ? OR phone LIKE ? OR LOWER(description) LIKE ?",
               term, term, term, term, term, term, term, term, term).all
    end
    return results.uniq
  end

  # Tells gmaps4rails if it already got the geocoordinates for that or not
  def gmaps
    return true if resource_type == 'Web'
    return false if read_attribute(:gmaps) == false # lets us flag entries for re-processing manually
    !(street_address_changed? or city_changed? or country_changed? or postal_changed?)
  end

  def is_approved=(value)
    value = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
    write_attribute(:is_approved, value)
    if value && email.present? && !@skip_approval_email
      UserMailer.listing_approved(self).deliver
    end
  end

  def self.to_csv(options = {})
    columns = REQUIRED_COLUMNS | column_names.reject {|c| c == 'category_id'} | ['to_delete']

    CSV.generate(options) do |csv|
      csv << columns
      all.each do |location|
        values = location.attributes.dup
        values['category'] = location.category.name
        values['subcategories'] = location.subcategories.map(&:name).join(';')
        values['to_delete'] = false
        csv << values.values_at(*columns)
      end
    end
  end

  def self.import(file)
    line_num = 2
    CSV.foreach(file.path, headers: true) do |row|
      location = find_by_id(row["id"]) || new
      location.skip_approval_email = true
      if location && row["to_delete"].present? && row["to_delete"].downcase == "true"
        location.destroy
      else
        location.attributes = row.to_hash.slice(*accessible_attributes)
        location.is_approved = true unless row['is_approved'].present?
        if category = Category.find_by_name(row['category'])
          location.category = category
        else
          raise "Category \"#{row['category']}\" not found. Line #{line_num} Record: #{location.inspect}"
        end

        row['subcategories'].present? && row['subcategories'].split(';').each do |s|
          location.subcategories = []
          if subcategory = Subcategory.find_by_name(s.strip)
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
    list do
      field :name
      field :street_address
      field :city
      field :bioregion
      field :province
      field :is_approved
      field :country
      field :postal
      field :category
      field :subcategories
      field :email
      field :resource_type
      field :gmaps
      field :created_at
      field :updated_at
    end
  end
end

