namespace :pricing do
  desc "Fetch and store pricings for all possible combinations"
  task fetch: :environment do
    FetchPricingJob.perform_now
  end
end
