require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  # -------------------------------------------- test_viewing_top_level_category
  def test_viewing_top_level_category
    c = FactoryGirl.create( :nested_category )
    3.times { FactoryGirl.create( :nested_category, parent: c ) }
    get :show, id: c.id
    assert_response :success
  end
  # -------------------------------------------- test_viewing_low_level_category
  def test_viewing_low_level_category
    c = FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) )
    get :show, id: c.id
    assert_response :success
  end
  # ---------------------------------------------- test_viewing_category_by_name
  def test_viewing_category_by_name
    c = FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) )
    get :show, top_level_name: c.parent.name, subcategory_name: c.name
    assert_response :success
    assert_equal( c, assigns( :category ) )
  end
  # ------------------------------------ test_viewing_top_level_category_by_name
  def test_viewing_top_level_category_by_name
    c = FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) )
    get :show, top_level_name: c.parent.name
    assert_response :success
    assert_equal( c.parent, assigns( :category ) )
  end
  # -------------------------------- test_category_viewing_is_not_case_sensitive
  def test_category_viewing_is_not_case_sensitive
    c = FactoryGirl.create( :nested_category, parent: FactoryGirl.create( :nested_category ) )
    get :show, top_level_name: c.parent.name.upcase
    assert_response :success
    assert_equal( c.parent, assigns( :category ) )
  end
end
