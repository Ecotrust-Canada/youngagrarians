class HomeController < ApplicationController
  def index
    render layout: 'basic'
  end
  def map
    render layout: false, embed: @embed
  end
end
