require 'test_helper'

class SoilControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
