class NestedCategory < ActiveRecord::Base
  attr_accessible :name, :parent
  scope :top_level, -> { where( parent_category_id: nil ) }
  has_many :category_location_tags, dependent: :destroy
  has_many :locations, through: :category_location_tags
  belongs_to :parent, class_name: 'NestedCategory', foreign_key: 'parent_id'
  has_many :children, class_name: 'NestedCategory', foreign_key: 'parent_id'
end
