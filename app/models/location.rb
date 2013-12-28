class Location < ActiveRecord::Base
  include Gmaps4rails::ActsAsGmappable
  acts_as_gmappable :process_geocoding => :process, :validation => false

  belongs_to :category
  has_and_belongs_to_many :subcategories

  attr_accessible :latitude, :longitude, :gmaps, :address, :name, :content, :bioregion, :phone, :url, :fb_url, 
                  :twitter_url, :description, :is_approved, :category_id, :resource_type, :email, :postal, :show_until,
                  :street_address, :city, :country_code, :country_name, :province_code, :province_name

  def gmaps4rails_address
    "#{address}"
  end

  def process    
    true
  end

  def as_json(options = nil)
    super :include => [ :category, :subcategories ], :except => [ :category_id, :is_approved ]
  end

  def self.search(term, province = nil)
    results = []
    if not term.nil? and not term.empty?
      term = term.downcase
      category = Category.where('LOWER(name) = ?', term).first
      subcategory = Category.where('LOWER(name) = ?', term).first
      if category
        results += Location.where(:is_approved => true).where('category_id', category.id).all        
      end
      if subcategory
        results += Location.joins(:subcategories).where(:is_approved => true).where('subcategories.id = ?', subcategory.id).all
      end
      term = "%#{term}%"
      results += Location.where(:is_approved => true)
        .where("LOWER(name) LIKE ? OR LOWER(address) LIKE ? OR LOWER(postal) LIKE ? OR LOWER(bioregion) LIKE ? OR phone LIKE ? OR LOWER(description) LIKE ?", 
               term, term, term, term, term, term).all 
    end
    return results.uniq
  end

  def is_approved=(value)
    write_attribute(:is_approved, value)
    if value
      UserMailer.listing_approved(self).deliver
    end
  end
  
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|      
      csv << column_names
      all.each do |location|
        csv << location.attributes.values_at(*column_names)
      end
    end
  end
  
end

 