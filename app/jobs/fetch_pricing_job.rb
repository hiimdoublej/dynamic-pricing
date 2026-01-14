class FetchPricingJob < ApplicationJob
  queue_as :default

  def perform
    combinations = PricingController::VALID_PERIODS.product(
      PricingController::VALID_HOTELS,
      PricingController::VALID_ROOMS
    ).map { |p, h, r| { period: p, hotel: h, room: r } }

    response = PricingService.fetch_pricing(combinations)

    return unless response && response["rates"]

    attributes = response["rates"].map do |rate_data|
      {
        period: rate_data["period"],
        hotel: rate_data["hotel"],
        room: rate_data["room"],
        price: rate_data["rate"]
      }
    end

    # rubocop:disable Rails/SkipsModelValidations
    RoomPrice.upsert_all(attributes, unique_by: [:period, :hotel, :room]) if attributes.any?
    # rubocop:enable Rails/SkipsModelValidations
  end
end
