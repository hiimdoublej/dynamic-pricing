namespace :pricing do
  desc "Fetch and store pricings for all possible combinations"
  task fetch: :environment do
    periods = PricingController::VALID_PERIODS
    hotels = PricingController::VALID_HOTELS
    rooms = PricingController::VALID_ROOMS

    attributes = []
    periods.each do |period|
      hotels.each do |hotel|
        rooms.each do |room|
          attributes << { period: period, hotel: hotel, room: room }
        end
      end
    end

    Rails.logger.info "Fetching pricing for #{attributes.size} combinations..."
    
    begin
      response = PricingService.fetch_pricing(attributes)
      rates = response["rates"]

      Rails.logger.info "Received #{rates.size} rates. Storing..."

      rates.each do |rate_data|
        RoomPrice.find_or_initialize_by(
          period: rate_data["period"],
          hotel: rate_data["hotel"],
          room: rate_data["room"]
        ).update!(price: rate_data["rate"])
      end

      Rails.logger.info "Successfully updated pricing."
    rescue => e
      Rails.logger.error "Failed to fetch pricing: #{e.message}"
      # We might want to re-raise if we want the cron job to report failure
      raise e
    end
  end
end
