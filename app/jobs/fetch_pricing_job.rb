class FetchPricingJob < ApplicationJob
  queue_as :default

  def perform
    combinations = PricingController::VALID_PERIODS.product(
      PricingController::VALID_HOTELS,
      PricingController::VALID_ROOMS
    ).map { |p, h, r| { period: p, hotel: h, room: r } }

    response = PricingService.fetch_pricing(combinations)

    return unless response && response["rates"]

    response["rates"].each do |rate_data|
      RoomPrice.find_or_initialize_by(period: rate_data["period"], hotel: rate_data["hotel"],
                                      room: rate_data["room"]).update!(price: rate_data["rate"])
    end
  end
end
