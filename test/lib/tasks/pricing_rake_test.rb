require "test_helper"
require "rake"

class PricingRakeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    # Load Rake tasks if not already loaded
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["pricing:fetch"].reenable
  end

  test "pricing:fetch executes FetchPricingJob immediately" do
    called = false
    FetchPricingJob.stub :perform_now, -> { called = true } do
      Rake::Task["pricing:fetch"].invoke
    end

    assert called
  end
end
