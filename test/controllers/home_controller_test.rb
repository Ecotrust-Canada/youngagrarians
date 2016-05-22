require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  # ------------------------------------------------------- test_viewing_sitemap
  def test_viewing_sitemap
    5.times{ FactoryGirl.create( :location ) }
    get :sitemap, format: 'xml'
    assert_response :success
  end
  # ------------------------------------------------------- test_viewing_sitemap
  def test_viewing_sitemap_with_top_level_categories
    3.times{ FactoryGirl.create( :nested_category, parent: nil ) }
    get :sitemap, format: 'xml'
    assert_response :success
  end
end
