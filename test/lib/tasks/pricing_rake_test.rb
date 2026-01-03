require "test_helper"
require "rake"
require "minitest/mock"

class PricingRakeTest < ActiveSupport::TestCase
  setup do
    # Load Rake tasks if not already loaded
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["pricing:fetch"].reenable
    
    # clear db
    RoomPrice.delete_all
  end

  test "pricing:fetch fetches and stores rates" do
    # Setup expected data
    expected_response = {
      "rates" => [
        { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "12345" },
        { "period" => "Winter", "hotel" => "GitawayHotel", "room" => "BooleanTwin", "rate" => "67890" }
      ]
    }

    # Verify the mocked call arguments
    mock_service_proc = ->(attributes) {
      # Verify that attributes contain the combinations we expect
      # We know there are 4 periods * 3 hotels * 3 rooms = 36 combinations
      # But checking the size is probably enough for this test
      expected_combinations = PricingController::VALID_PERIODS.product(
        PricingController::VALID_HOTELS,
        PricingController::VALID_ROOMS
      ).map { |p, h, r| { period: p, hotel: h, room: r } }
      
      # We can't easily check strict equality of array of hashes if order differs, 
      # but checking size and a sample is good.
      unless attributes.size == expected_combinations.size
        raise "Expected #{expected_combinations.size} attributes, got #{attributes.size}"
      end
      
      expected_response
    }

    # Stub the service
    PricingService.stub :fetch_pricing, mock_service_proc do
      # Run the rake task
      Rake::Task["pricing:fetch"].invoke
    end

    # Assertions
    assert_equal 2, RoomPrice.count
    
    price1 = RoomPrice.find_by(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom")
    assert_not_nil price1
    assert_equal 12345, price1.price

    price2 = RoomPrice.find_by(period: "Winter", hotel: "GitawayHotel", room: "BooleanTwin")
    assert_not_nil price2
    assert_equal 67890, price2.price
  end
  
  test "pricing:fetch updates existing rates" do
    # Create an existing record
    RoomPrice.create!(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom", price: 10000)
    
    expected_response = {
      "rates" => [
        { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "20000" }
      ]
    }
    
    mock_service_proc = ->(attributes) { expected_response }
    
    PricingService.stub :fetch_pricing, mock_service_proc do
      Rake::Task["pricing:fetch"].invoke
    end
    
    # Assertions
    assert_equal 1, RoomPrice.count
    price = RoomPrice.find_by(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom")
    assert_equal 20000, price.price
  end
end
