class CategoryTag < ActiveRecord::Base
  self.table_name= 'category_location_tags'
  # attr_accessible :title, :body
  belongs_to :location, inverse_of: :category_tags
  belongs_to :nested_category, foreign_key: 'category_id'
  validates :location, presence: true
  validates :nested_category, presence: true
end
