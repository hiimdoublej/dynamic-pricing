require "test_helper"
require "minitest/mock"

class PricingServiceTest < ActiveSupport::TestCase
  setup do
    @service = PricingService.new
  end

  test "fetches pricing successfully" do
    attributes = [
      { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" },
      { "period" => "Autumn", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" },
      { "period" => "Winter", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" },
      { "period" => "Spring", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" }
    ]

    expected_response_body = {
      "rates" => [
        { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "12000" },
        { "period" => "Autumn", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "28000" },
        { "period" => "Winter", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "46000" },
        { "period" => "Spring", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "73000" }
      ]
    }

    mock_response = Net::HTTPOK.new("1.1", 200, "OK")
    mock_response.instance_variable_set(:@body, expected_response_body.to_json)
    def mock_response.body; @body; end

    mock_http = Minitest::Mock.new
    mock_http.expect :use_ssl=, nil, [false]
    mock_http.expect :open_timeout=, nil, [5]
    mock_http.expect :read_timeout=, nil, [5]
    mock_http.expect :write_timeout=, nil, [5]
    mock_http.expect :send_request, mock_response do |method, path, body, headers|
      method == 'POST' && path == '/pricing' && JSON.parse(body) == { "attributes" => attributes }
    end

    Net::HTTP.stub :new, mock_http do
      result = @service.fetch_pricing(attributes)
      assert_equal expected_response_body, result
    end

    mock_http.verify
  end

  test "raises RateLimitExceeded on 429 response" do
    mock_response = Net::HTTPTooManyRequests.new("1.1", 429, "Too Many Requests")
    mock_response.instance_variable_set(:@body, { "error" => "Rate limit exceeded (1000/day)" }.to_json)
    def mock_response.body; @body; end

    mock_http = Minitest::Mock.new
    mock_http.expect :use_ssl=, nil, [false]
    mock_http.expect :open_timeout=, nil, [5]
    mock_http.expect :read_timeout=, nil, [5]
    mock_http.expect :write_timeout=, nil, [5]
    mock_http.expect :send_request, mock_response, [String, String, String, Hash]

    Net::HTTP.stub :new, mock_http do
      assert_raises(PricingService::RateLimitExceeded) do
        @service.fetch_pricing([])
      end
    end

    mock_http.verify
  end

  test "raises http exception on 500 response" do
    mock_response = Net::HTTPInternalServerError.new("1.1", 500, "Internal Server Error")
    mock_response.instance_variable_set(:@body, "Internal Server Error")
    def mock_response.body; @body; end

    mock_http = Minitest::Mock.new
    mock_http.expect :use_ssl=, nil, [false]
    mock_http.expect :open_timeout=, nil, [5]
    mock_http.expect :read_timeout=, nil, [5]
    mock_http.expect :write_timeout=, nil, [5]
    mock_http.expect :send_request, mock_response, [String, String, String, Hash]

    Net::HTTP.stub :new, mock_http do
      # Expecting a built-in Net::HTTP exception that corresponds to 5xx errors
      assert_raises(Net::HTTPFatalError, Net::HTTPServerException) do
        @service.fetch_pricing([])
      end
    end

    mock_http.verify
  end
end
