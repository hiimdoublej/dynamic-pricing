require "test_helper"

class PricingControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @period = "Summer"
    @hotel = "FloatingPointResort"
    @room = "SingletonRoom"
    @price = 12000

    RoomPrice.where(period: @period, hotel: @hotel, room: @room).destroy_all
    @room_price = RoomPrice.create!(
      period: @period, hotel: @hotel, room: @room, price: @price, updated_at: Time.current
    )
  end

  test "should get pricing with all parameters" do
    get_pricing(@period, @hotel, @room)

    assert_response :success
    assert_equal @price.to_s, JSON.parse(@response.body)["rate"]
  end

  test "should include cache control headers in successful response" do
    get_pricing(@period, @hotel, @room)

    assert_response :success
    cache_control = @response.headers["Cache-Control"]
    assert_includes cache_control, "public"
  end

  test "should include max-age and s-maxage in Cache-Control" do
    get_pricing(@period, @hotel, @room)

    cache_control = @response.headers["Cache-Control"]
    assert_match(/max-age=\d+/, cache_control)
    assert_match(/s-maxage=\d+/, cache_control)
  end

  test "should have correct cache-control values" do
    now = Time.current
    travel_to now do
      get_pricing(@period, @hotel, @room)

      cache_control = @response.headers["Cache-Control"]
      expected_s_maxage = (5.minutes - (now - @room_price.updated_at)).to_i
      actual_max_age = cache_control.match(/max-age=(\d+)/)[1].to_i
      actual_s_maxage = cache_control.match(/s-maxage=(\d+)/)[1].to_i

      assert_in_delta [expected_s_maxage / 2, 60].min, actual_max_age, 1
      assert_in_delta expected_s_maxage, actual_s_maxage, 1
    end
  end

  test "should return error when price is not found or expired" do
    get_pricing("Winter", @hotel, @room)
    assert_response :not_found

    @room_price.update!(updated_at: 6.minutes.ago)
    get_pricing(@period, @hotel, @room)
    assert_response :not_found
  end

  test "should return error for missing or empty parameters" do
    get pricing_url
    assert_response :bad_request

    get_pricing("", "", "")
    assert_response :bad_request
  end

  test "should reject invalid parameter values" do
    get_pricing("summer-2024", @hotel, @room)
    assert_response :bad_request

    get_pricing(@period, "InvalidHotel", @room)
    assert_response :bad_request

    get_pricing(@period, @hotel, "InvalidRoom")
    assert_response :bad_request
  end

  private

  def get_pricing(period, hotel, room)
    get pricing_url, params: { period: period, hotel: hotel, room: room }
  end
end
