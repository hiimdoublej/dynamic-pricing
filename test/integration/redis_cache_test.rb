require "test_helper"

class RedisCacheTest < ActiveSupport::TestCase
  test "redis cache get and set" do
    Rails.cache.write("test_key", "test_value")
    assert_equal "test_value", Rails.cache.read("test_key")
  end

  test "redis cache expiration" do
    Rails.cache.write("expired_key", "expired_value", expires_in: 1.second)
    assert_equal "expired_value", Rails.cache.read("expired_key")
    sleep 1.1
    assert_nil Rails.cache.read("expired_key")
  end
end
