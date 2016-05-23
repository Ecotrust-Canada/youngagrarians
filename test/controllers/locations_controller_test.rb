require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  def test_viewing_basic_location
    location = FactoryGirl.create( :location )
    get :show, id: location
    assert_response :success
  end
  
  def test_viewing_expired_location
    location = FactoryGirl.create( :location, show_until: 7.days.ago )
    get :show, id: location
    assert_response 404
  end

  def test_viewing_new_form
    3.times { FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) ) }
    get :new
    assert_response :success
    assert_template :new
  end
  
  def test_viewing_new_form_for_account_setup
    category = FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) )
    session[:in_progress_location] = { category_ids: [category.id] }
    get :new
    assert_response :success
    assert_template :account_setup
  end
  
  def test_viewing_new_form_for_details
    category = FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) )
    session[:in_progress_location] = { category_ids: [category.id], skip_account: true }
    get :new
    assert_response :success
    assert_template :details
  end
  
  def test_viewing_new_form_for_contact_details
    get :new, step: 'contact'
    assert_response :success
    assert_template :details
  end
end
