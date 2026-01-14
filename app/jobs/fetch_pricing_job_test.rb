require "test_helper"
require "minitest/mock"

class FetchPricingJobTest < ActiveJob::TestCase
  setup do
    RoomPrice.delete_all
  end

  test "perform fetches and stores rates" do
    response = {
      "rates" => [
        { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "12345" },
        { "period" => "Winter", "hotel" => "GitawayHotel", "room" => "BooleanTwin", "rate" => "67890" }
      ]
    }

    PricingService.stub :fetch_pricing, mock_service_proc(response) do
      FetchPricingJob.perform_now
    end

    assert_equal 2, RoomPrice.count
    assert_equal 12345, RoomPrice.find_by!(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom").price
    assert_equal 67890, RoomPrice.find_by!(period: "Winter", hotel: "GitawayHotel", room: "BooleanTwin").price
  end

  test "perform updates existing rates" do
    RoomPrice.create!(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom", price: 10000)

    expected_response = { "rates" => [{ "period" => "Summer", "hotel" => "FloatingPointResort",
                                        "room" => "SingletonRoom", "rate" => "20000" }] }
    PricingService.stub :fetch_pricing, ->(_) { expected_response } do
      FetchPricingJob.perform_now
    end

    assert_equal 20000, RoomPrice.find_by(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom").price
  end

  private

  def mock_service_proc(response)
    lambda { |attributes|
      expected_combinations = PricingController::VALID_PERIODS.product(
        PricingController::VALID_HOTELS,
        PricingController::VALID_ROOMS
      ).map { |p, h, r| { period: p, hotel: h, room: r } }

      unless attributes.size == expected_combinations.size
        raise "Expected #{expected_combinations.size} attributes, got #{attributes.size}"
      end

      response
    }
  end
end
