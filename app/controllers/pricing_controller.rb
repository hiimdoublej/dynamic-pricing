class PricingController < ApplicationController
  VALID_PERIODS = %w[Summer Autumn Winter Spring].freeze
  VALID_HOTELS = %w[FloatingPointResort GitawayHotel RecursionRetreat].freeze
  VALID_ROOMS = %w[SingletonRoom BooleanTwin RestfulKing].freeze

  before_action :validate_params

  def index
    period = params[:period]
    hotel  = params[:hotel]
    room   = params[:room]

    cache_key = "pricing:#{period}:#{hotel}:#{room}"
    price = Rails.cache.read(cache_key)

    unless price
      record = RoomPrice.find_by(period: period, hotel: hotel, room: room)

      # Ensure the rate is not older than 5 minutes
      if record && record.updated_at > 5.minutes.ago
        price = record.price
        expires_in = 5.minutes - (Time.current - record.updated_at)
        Rails.cache.write(cache_key, price, expires_in: expires_in)
      end
    end

    if price
      render json: { rate: price.to_s }
    else
      render json: { error: "Price not found or expired" }, status: :not_found
    end
  end

  private

  def validate_params
    # Validate required parameters
    unless params[:period].present? && params[:hotel].present? && params[:room].present?
      return render json: { error: "Missing required parameters: period, hotel, room" }, status: :bad_request
    end

    # Validate parameter values
    unless VALID_PERIODS.include?(params[:period])
      return render json: { error: "Invalid period. Must be one of: #{VALID_PERIODS.join(', ')}" }, status: :bad_request
    end

    unless VALID_HOTELS.include?(params[:hotel])
      return render json: { error: "Invalid hotel. Must be one of: #{VALID_HOTELS.join(', ')}" }, status: :bad_request
    end

    unless VALID_ROOMS.include?(params[:room])
      return render json: { error: "Invalid room. Must be one of: #{VALID_ROOMS.join(', ')}" }, status: :bad_request
    end
  end
end
