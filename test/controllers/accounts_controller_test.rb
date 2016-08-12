require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  # ---------------------------------------------------- test_password_retrieval
  def test_password_retrieval
    user = FactoryGirl.create( :user )
    post :retrieve_password, email: user.email
    assert_response :success
    assert( ActionMailer::Base.deliveries.first )
  end
end
