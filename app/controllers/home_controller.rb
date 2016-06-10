class HomeController < ApplicationController
  after_action :allow_iframe
  def index
    render layout: 'basic'
  end
  def map
    render layout: false
  end

private
  def allow_iframe
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end
end
