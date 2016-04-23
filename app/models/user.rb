class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # include Mongoid::Document
  include Passwordable

  attr_accessible :first_name, :last_name, :username, :email

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :username
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email,
                      with: %r{\A([-a-z0-9!\#$%&'*+/=?^_`{|}~]+\.)*
                               [-a-z0-9!\#$%&'*+/=?^_`{|}~]+
                               @
                               ((?:[-a-z0-9]+\.)+[a-z]{2,})\Z}ix

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
