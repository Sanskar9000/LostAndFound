require "test_helper"

class VerificationControllerTest < ActionDispatch::IntegrationTest
  test "should get pending" do
    get verification_pending_url
    assert_response :success
  end
end
