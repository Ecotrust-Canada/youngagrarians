class ListingComment < ActiveRecord::Base
  include Rakismet::Model
  rakismet_attrs :author => :name, :author_email => :email, :content => :body
  belongs_to :location
end
