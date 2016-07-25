class NestedCategory < ActiveRecord::Base
  MAX_DEPTH = 4
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

  # --------------------------------------------------------- primary_categories
  def self.primary_categories
    NestedCategory.joins( 'JOIN nested_categories meta ON meta.id = nested_categories.parent_category_id' )
                  .where( 'meta.parent_category_id IS NULL' )
                  .select( 'nested_categories.*, meta.name AS meta_name, meta.id AS meta_id' )
  end


  # ---------------------------------------------------------------- meta_lookup
  def self.meta_lookup
    scopes = []
    MAX_DEPTH.times do |i|
      joins = i.times.to_a.map do |j|
        previous_table = j == 0 ? 'nested_categories' : "nested_categories_#{j-1}"
        "JOIN nested_categories nested_categories_#{j} ON nested_categories_#{j}.parent_category_id = #{previous_table}.id"
      end
      scopes.push( unscoped
                   .select( format( 'nested_categories.name, nested_categories.id, %s, %s, %s',
                                    i == 0 ? 'nested_categories.id' : "nested_categories_#{i-1}.id",
                                    i == 0 ? 'NULL' : "nested_categories_0.id",
                                    i == 0 ? 'NULL' : "nested_categories_0.name",

                                    ) )
                   .joins( joins.join( ' ' ) ) )
    end
    query = scopes.map( &:to_sql ).join( " UNION ALL " )
    r_val = {}
    connection.select_rows( query ).each do |meta_name, meta_id, leaf_id, primary_id, primary_name|
      r_val[ leaf_id.to_i ] = { meta: { name: meta_name, id: meta_id.to_i },
                                primary: { name: primary_name, id: primary_id.to_i } }
    end
    r_val
  end
  
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
  # ----------------------------------------------------------------- leaf_node?
  def leaf_node?
    children.empty?
  end
  rails_admin do
    label 'Category'
  end
end
