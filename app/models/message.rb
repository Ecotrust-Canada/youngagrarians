class Message 
  attr_accessor :name, :subject, :email, :subject, :message
  include ActiveModel::Validations
  include ActiveModel::Model
  include ActiveModel::ForbiddenAttributesProtection
  attr_accessor :entity

  include Honeypot

  has_honeypot( :link )
end
