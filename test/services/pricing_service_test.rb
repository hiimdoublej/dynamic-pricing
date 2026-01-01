require "test_helper"
require "minitest/mock"

class PricingServiceTest < ActiveSupport::TestCase
  setup do
    @service = PricingService.new
    @example_request_attributes = [
      { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" },
      { "period" => "Autumn", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" },
      { "period" => "Winter", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" },
      { "period" => "Spring", "hotel" => "FloatingPointResort", "room" => "SingletonRoom" }
    ]
    @example_response_body = {
      "rates" => [
        { "period" => "Summer", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "12000" },
        { "period" => "Autumn", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "28000" },
        { "period" => "Winter", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "46000" },
        { "period" => "Spring", "hotel" => "FloatingPointResort", "room" => "SingletonRoom", "rate" => "73000" }
      ]
    }
  end

  test "fetches pricing successfully" do
    mock_response = Net::HTTPOK.new("1.1", 200, "OK")
    mock_response.instance_variable_set(:@body, @example_response_body.to_json)
    def mock_response.body; @body; end

    mock_http = create_mock_http(mock_response, @example_request_attributes)

    Net::HTTP.stub :new, mock_http do
      result = @service.fetch_pricing(@example_request_attributes)
      assert_equal @example_response_body, result
    end

    mock_http.verify
  end

  test "raises RateLimitExceeded on 429 response" do
    mock_response = Net::HTTPTooManyRequests.new("1.1", 429, "Too Many Requests")
    mock_response.instance_variable_set(:@body, { "error" => "Rate limit exceeded (1000/day)" }.to_json)
    def mock_response.body; @body; end

    mock_http = create_mock_http(mock_response, @example_request_attributes)

    Net::HTTP.stub :new, mock_http do
      assert_raises(PricingService::RateLimitExceeded) do
        @service.fetch_pricing(@example_request_attributes)
      end
    end

    mock_http.verify
  end

  test "raises http exception on 500 response" do
    mock_response = Net::HTTPInternalServerError.new("1.1", 500, "Internal Server Error")
    mock_response.instance_variable_set(:@body, "Internal Server Error")
    def mock_response.body; @body; end

    mock_http = create_mock_http(mock_response, @example_request_attributes)

    Net::HTTP.stub :new, mock_http do
      # Expecting a built-in Net::HTTP exception that corresponds to 5xx errors
      assert_raises(Net::HTTPFatalError, Net::HTTPServerException) do
        @service.fetch_pricing(@example_request_attributes)
      end
    end

    mock_http.verify
  end

  test "raises RateLimitExceeded even if 429 response body is not valid JSON" do
    mock_response = Net::HTTPTooManyRequests.new("1.1", 429, "Too Many Requests")
    mock_response.instance_variable_set(:@body, "Too Many Requests") # Non-JSON body
    def mock_response.body; @body; end

    mock_http = create_mock_http(mock_response, @example_request_attributes)

    Net::HTTP.stub :new, mock_http do
      assert_raises(PricingService::RateLimitExceeded) do
        @service.fetch_pricing(@example_request_attributes)
      end
    end

    mock_http.verify
  end

  private

  def create_mock_http(mock_response, expected_attributes)
    # From https://hub.docker.com/r/tripladev/rate-api

    mock_http = Minitest::Mock.new
    def mock_http.use_ssl=(*); end
    def mock_http.open_timeout=(*); end
    def mock_http.read_timeout=(*); end
    def mock_http.write_timeout=(*); end

    mock_http.expect :send_request, mock_response do |method, path, body, headers|
      method == 'POST' && path == '/pricing' && JSON.parse(body) == { "attributes" => expected_attributes }
    end

    mock_http
  end
end
