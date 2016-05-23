class NestedCategory < ActiveRecord::Base
  validates :name, presence: true
  scope :top_level, -> { where( parent_category_id: nil ) }
  scope :meta, -> { where( parent_category_id: nil ) }
  has_many :category_location_tags, dependent: :destroy, class_name: 'CategoryTag', foreign_key: 'category_id'
  has_many :locations, through: :category_location_tags
  belongs_to :parent, class_name: 'NestedCategory', foreign_key: 'parent_category_id'
  has_many :children, class_name: 'NestedCategory', foreign_key: 'parent_category_id'
  scope :by_name, proc { |x|
    where( arel_table[:name].matches( x ) )
  }
  
  rails_admin do
    configure :category_location_tags do
      visible( false )
    end
    configure :locations do
      visible( false )
    end
    configure :children do
      visible( false )
    end
    list do
      field :name
    end
  end

  # ---------------------------------------------------------------------- meta?
  def meta?
    parent.nil?
  end
end
