#
class Location < ActiveRecord::Base
  include Gmaps4rails::ActsAsGmappable
  acts_as_gmappable validation: false

  belongs_to :category
  has_and_belongs_to_many :subcategories

  # TODO: security issue, need to not allow is_approved to be sset by just anybody.
  attr_accessible :latitude, :longitude, :name, :content, :bioregion, :phone, :url, :fb_url,
                  :twitter_url, :description, :is_approved, :category_id, :resource_type, :email, :postal, :show_until,
                  :street_address, :city, :country, :province, :gmaps, :subcategory_ids

  REQUIRED_COLUMNS = %w(id resource_type category subcategories
                        name bioregion street_address city province country postal phone
                        url fb_url twitter_url description email).freeze

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

  def is_approved=(value)
    value = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
    self[:is_approved] = value
    if value && email.present? && !@skip_approval_email
      UserMailer.listing_approved(self).deliver
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
