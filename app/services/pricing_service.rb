require 'net/http'
require 'json'

class PricingService
  class RateLimitExceeded < StandardError; end

  def self.fetch_pricing(attributes)
    new.fetch_pricing(attributes)
  end

  def fetch_pricing(attributes)
    send_request('POST', '/pricing', { attributes: attributes })
  end

  private

  def send_request(method, path, body = {}, headers = {})
    config = Rails.application.config_for(:pricing_service)
    uri = URI(config[:host])
    token = config[:token]
    timeout = config[:timeout].to_i

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = timeout
    http.read_timeout = timeout
    http.write_timeout = timeout

    body = body.to_json
    default_headers = {
      'Content-Type' => 'application/json',
      'token' => token,
    }
    response = http.send_request(method, path, body, default_headers.merge(headers))

    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPTooManyRequests
      Rails.logger.warn("Pricing API rate limit exceeded: #{response.body}")
      raise RateLimitExceeded, response.body
    else
      Rails.logger.error("Pricing API error: #{response.code} #{response.body}")
      response.value
    end
  rescue StandardError => e
    Rails.logger.error("Pricing API connection error: #{e.message}")
    raise e
  end
end
