class CleanupReviewAppJob < ActiveJob::Base
  queue_as :default

  def perform(reviewapp)
    reviewapp.destroy
  end
end
