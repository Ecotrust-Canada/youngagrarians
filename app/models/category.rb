class Category < ActiveRecord::Base
  has_many :locations
  has_many :subcategories
  validates :name, presence: true

  def as_json(_options)
    super include: :subcategories
  end
end
