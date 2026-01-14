class PricingController < ApplicationController
  VALID_PERIODS = %w[Summer Autumn Winter Spring].freeze
  VALID_HOTELS = %w[FloatingPointResort GitawayHotel RecursionRetreat].freeze
  VALID_ROOMS = %w[SingletonRoom BooleanTwin RestfulKing].freeze

  before_action :validate_params

  def index
    price, @expires_at = find_record

    if price
      set_cache_control_headers
      render json: { rate: price.to_s }
    else
      render json: { error: "Price not found or expired" }, status: :not_found
    end
  end

  private

  def find_record
    cache_key = "pricing:#{params[:period]}:#{params[:hotel]}:#{params[:room]}"
    cached_data = Rails.cache.read(cache_key)
    return cached_data if cached_data

    record = RoomPrice.find_by(period: params[:period], hotel: params[:hotel], room: params[:room])
    return [nil, nil] unless record && record.updated_at > 5.minutes.ago

    expires_at = record.updated_at + 5.minutes
    data = [record.price, expires_at]
    Rails.cache.write(cache_key, data, expires_in: (expires_at - Time.current))

    data
  end

  def set_cache_control_headers
    return unless @expires_at

    s_maxage = [0, (@expires_at - Time.current).to_i].max
    max_age = [(s_maxage / 2), 60].min
    response.headers["Cache-Control"] = "public, max-age=#{max_age}, s-maxage=#{s_maxage}"
  end

  def validate_params
    # Validate required parameters
    unless params[:period].present? && params[:hotel].present? && params[:room].present?
      return render json: { error: "Missing required parameters: period, hotel, room" }, status: :bad_request
    end

    # Validate parameter values
    validate_parameter_values
  end

  def validate_parameter_values
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
