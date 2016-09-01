require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  # --------------------------------------------- test_viewing_list_of_locations
  def test_viewing_list_of_locations
    get :index, format: 'json'
    assert_response :success
  end
  def test_searching_for_locations
    get :index, format: 'json', q: 'permaculture'
    assert_response :success
  end
end
