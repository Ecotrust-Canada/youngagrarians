class Account < ActiveRecord::Base
  has_secure_password
  validates :email, uniqueness: true

  has_many :locations, inverse_of: :account

end
