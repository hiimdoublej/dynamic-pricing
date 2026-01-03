require "test_helper"

class RoomPriceTest < ActiveSupport::TestCase
  def setup
    @price = RoomPrice.new(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom", price: 10000)
  end

  test "should be valid" do
    assert @price.valid?
  end

  test "should require period" do
    @price.period = nil
    assert_not @price.valid?
  end

  test "should require hotel" do
    @price.hotel = nil
    assert_not @price.valid?
  end

  test "should require room" do
    @price.room = nil
    assert_not @price.valid?
  end

  test "should require price" do
    @price.price = nil
    assert_not @price.valid?
  end

  test "should enforce uniqueness of period, hotel, and room combination" do
    @price.save
    duplicate_price = @price.dup
    assert_not duplicate_price.valid?
  end
end
