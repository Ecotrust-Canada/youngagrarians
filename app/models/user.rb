class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  # include Mongoid::Document
  include Passwordable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true
  validates :email, presence: true,
                    format:  { with: %r{\A([-a-z0-9!\#$%&'*+/=?^_`{|}~]+\.)*
                                        [-a-z0-9!\#$%&'*+/=?^_`{|}~]+
                                        @
                                        ((?:[-a-z0-9]+\.)+[a-z]{2,})\Z}ix }
  before_validation :sanitize_data

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def sanitize_data
    # We want lowercase emails to make it easy to look up via authentication!
    self.email = email.downcase.strip if email
  end
end
