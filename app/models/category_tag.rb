class CategoryTag < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :location 
  belongs_to :nested_category
  validates :location, presence: true
  validates :nested_category, presence: true
end
