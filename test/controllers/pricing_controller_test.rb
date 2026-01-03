require "test_helper"

class PricingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @period = "Summer"
    @hotel = "FloatingPointResort"
    @room = "SingletonRoom"
    @price = 12000

    # Ensure clean state for the specific combination we use in happy path
    RoomPrice.where(period: @period, hotel: @hotel, room: @room).destroy_all
    
    # Create a fresh price for the happy path
    @room_price = RoomPrice.create!(
      period: @period,
      hotel: @hotel,
      room: @room,
      price: @price,
      updated_at: Time.current
    )
  end

  test "should get pricing with all parameters" do
    get pricing_url, params: {
      period: @period,
      hotel: @hotel,
      room: @room
    }

    assert_response :success
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal @price.to_s, json_response["rate"]
  end

  test "should return error when price is not found" do
    # Requesting a combination that doesn't exist (assuming Winter is valid but not in DB)
    get pricing_url, params: {
      period: "Winter",
      hotel: @hotel,
      room: @room
    }

    assert_response :not_found
    json_response = JSON.parse(@response.body)
    assert_equal "Price not found or expired", json_response["error"]
  end

  test "should return error when price is expired" do
    # Update the existing price to be old
    @room_price.update!(updated_at: 6.minutes.ago)

    get pricing_url, params: {
      period: @period,
      hotel: @hotel,
      room: @room
    }

    assert_response :not_found
    json_response = JSON.parse(@response.body)
    assert_equal "Price not found or expired", json_response["error"]
  end

  test "should return error without any parameters" do
    get pricing_url

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Missing required parameters"
  end

  test "should handle empty parameters" do
    get pricing_url, params: {
      period: "",
      hotel: "",
      room: ""
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Missing required parameters"
  end

  test "should reject invalid period" do
    get pricing_url, params: {
      period: "summer-2024",
      hotel: @hotel,
      room: @room
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Invalid period"
  end

  test "should reject invalid hotel" do
    get pricing_url, params: {
      period: @period,
      hotel: "InvalidHotel",
      room: @room
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Invalid hotel"
  end

  test "should reject invalid room" do
    get pricing_url, params: {
      period: @period,
      hotel: @hotel,
      room: "InvalidRoom"
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Invalid room"
  end
end