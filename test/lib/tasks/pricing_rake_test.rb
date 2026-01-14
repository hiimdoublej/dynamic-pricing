require "test_helper"
require "rake"

class PricingRakeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    # Load Rake tasks if not already loaded
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["pricing:fetch"].reenable
  end

  test "pricing:fetch enqueues FetchPricingJob" do
    assert_enqueued_with(job: FetchPricingJob) do
      Rake::Task["pricing:fetch"].invoke
    end
  end
end
