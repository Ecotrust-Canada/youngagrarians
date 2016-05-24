class NestedCategory < ActiveRecord::Base
  validates :name, presence: true
  scope :top_level, -> { where( parent_category_id: nil ) }
  scope :meta, -> { where( parent_category_id: nil ) }
  scope :level_2, -> { unscoped
                       .joins( "JOIN nested_categories parents ON parents.id = nested_categories.parent_category_id" )
                       .where( 'parents.parent_category_id' => nil )
                       .select( 'nested_categories.*, parents.name AS parent_name' )
                       }
  scope :no_children, -> { joins( "LEFT OUTER JOIN nested_categories children ON children.parent_category_id = nested_categories.id" )
                           .where( 'children.id IS NULL' ) }
  scope :with_children, -> { joins( "JOIN nested_categories children ON children.parent_category_id = nested_categories.id" )
                             .select( 'DISTINCT nested_categories.*' )
                             .includes( :children ) }
  default_scope -> { order( 'name' ) }
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
