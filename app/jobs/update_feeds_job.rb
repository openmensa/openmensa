# frozen_string_literal: true

# Replaced by FetchFeedJob and ScheduleFeedsJob. Kept for one release so
# that jobs enqueued before the deployment are discarded without errors.
#
# TODO: Remove with the next release.
class UpdateFeedsJob < ApplicationJob
  def perform; end
end
