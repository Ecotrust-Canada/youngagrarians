class HomeController < ApplicationController
  def index
    @json = Location.where(is_approved: true).all.to_gmaps4rails
  end
  def map
    render layout: false
  end
end
