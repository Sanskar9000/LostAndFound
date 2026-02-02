require "test_helper"

class StaffClaimsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get staff_claims_index_url
    assert_response :success
  end
end
