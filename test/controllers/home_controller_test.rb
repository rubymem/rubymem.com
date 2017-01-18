require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_path
    assert_response :success
  end

  test "should get atom feed" do
    FactoryGirl.create_list(:rubysec_advisory, 5, imported: true)
    get feed_path
    assert_response :success
  end

end

